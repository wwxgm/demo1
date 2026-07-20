import 'package:flutter_test/flutter_test.dart';
import 'package:autovi/main.dart';

void main() {
  testWidgets('shows single video flip action', (tester) async {
    await tester.pumpWidget(const AutoVideoFlipApp());

    expect(find.text('自动翻转视频'), findsOneWidget);
    expect(find.text('选择视频并自动翻转'), findsOneWidget);
  });
}
