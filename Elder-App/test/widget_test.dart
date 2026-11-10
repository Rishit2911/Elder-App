import 'package:flutter_test/flutter_test.dart';
import 'package:elderly_seva/main.dart';

void main() {
  testWidgets('Elderly Seva Welcome Screen smoke test', (WidgetTester tester) async {
    // Build Elderly Seva app and trigger a frame.
    await tester.pumpWidget(const ElderlySevaApp());
    await tester.pumpAndSettle();

    // Verify Welcome Screen elements
    expect(find.text('ELDERLY SEVA'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
