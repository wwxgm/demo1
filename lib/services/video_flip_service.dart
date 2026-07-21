import 'package:flutter/services.dart';

class VideoFlipException implements Exception {
  const VideoFlipException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VideoFlipService {
  const VideoFlipService();

  static const MethodChannel _channel = MethodChannel('autovi/video_flip');

  Future<String> pickFlipAndSaveVideo() async {
    try {
      final result = await _channel.invokeMethod<String>('pickFlipAndSaveVideo');
      if (result == null || result.isEmpty) {
        throw const VideoFlipException('没有收到 iOS 处理结果。');
      }
      return result;
    } on PlatformException catch (error) {
      throw VideoFlipException(error.message ?? error.code);
    }
  }
}
