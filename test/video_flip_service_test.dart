import 'package:flutter_test/flutter_test.dart';
import 'package:autovi/services/video_flip_service.dart';

void main() {
  test('VideoFlipException renders message', () {
    const error = VideoFlipException('处理失败');

    expect(error.toString(), '处理失败');
  });
}
