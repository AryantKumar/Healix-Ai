import 'package:flutter_test/flutter_test.dart';
import 'package:healix_ai/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(const HealixApp());
    expect(find.text('Healix AI'), findsOneWidget);
  });
}
