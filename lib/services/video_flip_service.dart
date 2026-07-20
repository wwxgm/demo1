import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VideoFlipException implements Exception {
  const VideoFlipException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VideoFlipService {
  const VideoFlipService();

  Future<String> flipVideoHorizontally(String inputPath) async {
    final tempDirectory = await getTemporaryDirectory();
    final outputPath = p.join(
      tempDirectory.path,
      'autovi_hflip_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    final session = await FFmpegKit.execute(
      buildHorizontalFlipCommand(inputPath: inputPath, outputPath: outputPath),
    );
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }

    final failStackTrace = await session.getFailStackTrace();
    final logs = await session.getAllLogsAsString();
    throw VideoFlipException(
      failStackTrace?.isNotEmpty == true
          ? failStackTrace!
          : logs.isNotEmpty
              ? logs
              : 'FFmpeg video flip failed.',
    );
  }

  static String buildHorizontalFlipCommand({
    required String inputPath,
    required String outputPath,
  }) {
    return [
      '-y',
      '-i ${_quote(inputPath)}',
      '-vf hflip',
      '-map_metadata 0',
      '-c:a copy',
      '-movflags +faststart',
      _quote(outputPath),
    ].join(' ');
  }

  static String _quote(String value) {
    return '"${value.replaceAll('"', '\\"')}"';
  }
}
