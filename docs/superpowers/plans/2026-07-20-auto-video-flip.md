# Auto Video Flip Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter MVP that picks one video, horizontally flips it, and saves the result to the phone gallery.

**Architecture:** The app has a small UI in `lib/main.dart` and isolates FFmpeg command construction/execution in `lib/services/video_flip_service.dart`. Native media access is delegated to Flutter plugins: `file_picker`, `ffmpeg_kit_flutter_new`, `path_provider`, and `gallery_saver_plus`.

**Tech Stack:** Flutter, Dart, FFmpegKit, File Picker, Gallery Saver Plus, GitHub Actions macOS build.

---

### Task 1: Project Scaffold

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `lib/main.dart`
- Create: `lib/services/video_flip_service.dart`

- [x] Create a minimal Flutter package structure that can be restored by `flutter pub get`.
- [x] Add dependencies for picking a video, processing via FFmpeg, temp-file output, and gallery saving.

### Task 2: Video Flip Service

**Files:**
- Create: `lib/services/video_flip_service.dart`
- Create: `test/video_flip_service_test.dart`

- [x] Add `VideoFlipService.buildHorizontalFlipCommand` so command construction can be unit-tested without device plugins.
- [x] Add `VideoFlipService.flipVideoHorizontally` to execute FFmpeg with `hflip` and copy audio.

### Task 3: MVP UI

**Files:**
- Create: `lib/main.dart`

- [x] Add one-button flow: pick one video, process, save to gallery.
- [x] Show status messages for idle, processing, success, cancel, and errors.

### Task 4: Platform Permissions

**Files:**
- Create: `ios/Runner/Info.plist`
- Create: `android/app/src/main/AndroidManifest.xml`

- [x] Add photo-library/video picker usage descriptions for iOS.
- [x] Add Android gallery/storage permissions compatible with common Android versions.

### Task 5: Cloud Build Notes

**Files:**
- Create: `.github/workflows/flutter-ios-build.yml`
- Create: `README.md`

- [x] Add a GitHub Actions macOS workflow that builds an unsigned iOS app archive.
- [x] Document that real IPA installation on iPhone needs signing through Apple credentials or a local signing tool such as Sideloadly after obtaining an IPA-compatible build artifact.

### Verification

Local machine currently has no `flutter` command in PATH, so full build verification must run on a Flutter/macOS environment or GitHub Actions. Static files are present and ready for dependency restore.
