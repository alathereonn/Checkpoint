import 'package:checkpoint/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds Checkpoint app', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CheckpointApp()));
    expect(find.byType(CheckpointApp), findsOneWidget);
  });
}
