import AVFoundation
import Flutter
import Photos
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private var pendingResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "autovi/video_flip",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickFlipAndSaveVideo" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.pickVideo(result: result)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func pickVideo(result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(FlutterError(code: "BUSY", message: "正在处理上一个视频。", details: nil))
      return
    }

    guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
      result(FlutterError(code: "NO_LIBRARY", message: "无法打开相册。", details: nil))
      return
    }

    pendingResult = result
    let picker = UIImagePickerController()
    picker.sourceType = .photoLibrary
    picker.mediaTypes = [UTType.movie.identifier]
    picker.videoQuality = .typeHigh
    picker.delegate = self

    DispatchQueue.main.async {
      self.window?.rootViewController?.present(picker, animated: true)
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.finish("已取消选择。")
    }
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true) {
      guard let inputURL = info[.mediaURL] as? URL else {
        self.finishError(code: "NO_VIDEO", message: "没有获取到视频文件。")
        return
      }

      self.flipAndSave(inputURL: inputURL)
    }
  }

  private func flipAndSave(inputURL: URL) {
    let asset = AVAsset(url: inputURL)
    guard let videoTrack = asset.tracks(withMediaType: .video).first else {
      finishError(code: "NO_TRACK", message: "视频里没有可处理的视频轨道。")
      return
    }

    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("autovi_hflip_\(Int(Date().timeIntervalSince1970)).mp4")
    try? FileManager.default.removeItem(at: outputURL)

    let composition = AVMutableComposition()
    guard let compositionVideoTrack = composition.addMutableTrack(
      withMediaType: .video,
      preferredTrackID: kCMPersistentTrackID_Invalid
    ) else {
      finishError(code: "COMPOSITION", message: "无法创建视频合成轨道。")
      return
    }

    do {
      try compositionVideoTrack.insertTimeRange(
        CMTimeRange(start: .zero, duration: asset.duration),
        of: videoTrack,
        at: .zero
      )
    } catch {
      finishError(code: "INSERT_TRACK", message: "读取视频失败：\(error.localizedDescription)")
      return
    }

    if let audioTrack = asset.tracks(withMediaType: .audio).first,
       let compositionAudioTrack = composition.addMutableTrack(
         withMediaType: .audio,
         preferredTrackID: kCMPersistentTrackID_Invalid
       ) {
      try? compositionAudioTrack.insertTimeRange(
        CMTimeRange(start: .zero, duration: asset.duration),
        of: audioTrack,
        at: .zero
      )
    }

    let transformedSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
    let renderSize = CGSize(width: abs(transformedSize.width), height: abs(transformedSize.height))
    let mirrorTransform = CGAffineTransform(translationX: renderSize.width, y: 0).scaledBy(x: -1, y: 1)
    let finalTransform = videoTrack.preferredTransform.concatenating(mirrorTransform)

    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
    layerInstruction.setTransform(finalTransform, at: .zero)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
    instruction.layerInstructions = [layerInstruction]

    let videoComposition = AVMutableVideoComposition()
    videoComposition.instructions = [instruction]
    videoComposition.renderSize = renderSize
    videoComposition.frameDuration = CMTime(value: 1, timescale: max(24, Int32(videoTrack.nominalFrameRate)))

    guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
      finishError(code: "EXPORTER", message: "无法创建视频导出器。")
      return
    }

    exporter.outputURL = outputURL
    exporter.outputFileType = .mp4
    exporter.videoComposition = videoComposition
    exporter.shouldOptimizeForNetworkUse = true

    exporter.exportAsynchronously {
      DispatchQueue.main.async {
        if exporter.status == .completed {
          self.saveToPhotos(outputURL: outputURL)
        } else {
          self.finishError(
            code: "EXPORT_FAILED",
            message: exporter.error?.localizedDescription ?? "视频翻转导出失败。"
          )
        }
      }
    }
  }

  private func saveToPhotos(outputURL: URL) {
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
      guard status == .authorized || status == .limited else {
        self.finishError(code: "PHOTO_DENIED", message: "没有相册写入权限。")
        return
      }

      PHPhotoLibrary.shared().performChanges {
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
      } completionHandler: { success, error in
        if success {
          self.finish("保存成功：请到手机相册查看。")
        } else {
          self.finishError(code: "SAVE_FAILED", message: error?.localizedDescription ?? "保存到相册失败。")
        }
      }
    }
  }

  private func finish(_ message: String) {
    DispatchQueue.main.async {
      self.pendingResult?(message)
      self.pendingResult = nil
    }
  }

  private func finishError(code: String, message: String) {
    DispatchQueue.main.async {
      self.pendingResult?(FlutterError(code: code, message: message, details: nil))
      self.pendingResult = nil
    }
  }
}
