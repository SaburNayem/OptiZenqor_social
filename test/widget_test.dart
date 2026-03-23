import 'package:flutter_test/flutter_test.dart';

import 'package:optizenqor_social/app.dart';

void main() {
  testWidgets('App bootstraps to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OptiZenqorApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('OptiZenqor Social'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
