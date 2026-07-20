# Auto Video Flip

Flutter MVP：选择 1 个视频，自动水平镜像翻转，然后保存到手机相册。

## 功能

- 选择单个视频
- 使用 FFmpeg `hflip` 水平翻转
- 保留原视频音频流
- 保存处理后的视频到 iOS Photos / Android Gallery

## 本地环境

你当前 Windows 电脑没有安装 Flutter，所以本地暂时不能直接运行：

```powershell
flutter --version
flutter pub get
flutter test
flutter run
```

如果后续要本地开发，需要安装 Flutter SDK，并把 `flutter\bin` 加到 `PATH`。

## 云构建 iOS

已提供 GitHub Actions 配置：

```text
.github/workflows/flutter-ios-build.yml
```

推送到 GitHub 后，在 Actions 里运行 `Build iOS app`，会生成一个 `unsigned-autovi-ipa` 构建产物。

注意：iPhone 安装仍需要签名。常见路径：

1. 云端或 Mac 上生成 iOS 构建产物。
2. 使用 Apple 开发者证书签名，或尝试用 Sideloadly 对 IPA 重新签名安装。
3. 免费 Apple ID 通常 7 天后需要重新签名安装。

## Android

有 Flutter 环境后可运行：

```powershell
flutter build apk --release
```

生成的 APK 在：

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 重要说明

`ffmpeg_kit_flutter_new` 是带 FFmpeg 能力的维护分支。视频编解码依赖可能涉及 LGPL/GPL 许可；如果只是个人自用问题不大，如果要商业上架，需要再单独确认依赖许可和替代方案。
