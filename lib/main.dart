import 'package:flutter/material.dart';

import 'services/video_flip_service.dart';

void main() {
  runApp(const AutoVideoFlipApp());
}

class AutoVideoFlipApp extends StatelessWidget {
  const AutoVideoFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Video Flip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6FED)),
        useMaterial3: true,
      ),
      home: const VideoFlipPage(),
    );
  }
}

class VideoFlipPage extends StatefulWidget {
  const VideoFlipPage({super.key});

  @override
  State<VideoFlipPage> createState() => _VideoFlipPageState();
}

class _VideoFlipPageState extends State<VideoFlipPage> {
  final VideoFlipService _videoFlipService = const VideoFlipService();

  bool _isProcessing = false;
  String _status = '请选择一个视频，App 会自动水平翻转并保存到相册。';

  Future<void> _pickFlipAndSave() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = '请选择一个视频，随后会自动水平翻转并保存到相册...';
    });

    try {
      final result = await _videoFlipService.pickFlipAndSaveVideo();
      setState(() => _status = result);
    } catch (error) {
      setState(() => _status = '处理失败：$error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自动翻转视频')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.flip, size: 72),
              const SizedBox(height: 24),
              Text(
                '水平镜像翻转',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isProcessing) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 24),
              ],
              FilledButton.icon(
                onPressed: _isProcessing ? null : _pickFlipAndSave,
                icon: const Icon(Icons.video_library),
                label: Text(_isProcessing ? '处理中...' : '选择视频并自动翻转'),
              ),
              const Spacer(),
              Text(
                '第一版仅处理单个视频。长视频可能耗时较久，建议先用短视频测试。',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
