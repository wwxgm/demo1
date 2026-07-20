import 'package:flutter_test/flutter_test.dart';
import 'package:autovi/services/video_flip_service.dart';

void main() {
  test('buildHorizontalFlipCommand applies hflip and keeps audio stream', () {
    final command = VideoFlipService.buildHorizontalFlipCommand(
      inputPath: '/tmp/input video.mov',
      outputPath: '/tmp/output video.mp4',
    );

    expect(command, contains('-vf hflip'));
    expect(command, contains('-c:a copy'));
    expect(command, contains('"/tmp/input video.mov"'));
    expect(command, contains('"/tmp/output video.mp4"'));
  });
}
