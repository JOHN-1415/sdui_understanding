import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_mobile_app/main.dart';

void main() {
  testWidgets('SDUI App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SDUIMobileApp());
    expect(find.byType(SDUIMobileApp), findsOneWidget);
  });
}
