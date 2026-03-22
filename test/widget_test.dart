import 'package:flutter_test/flutter_test.dart';

import 'package:optizenqor_social/app.dart';

void main() {
  testWidgets('App bootstraps to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OptiZenqorApp());

    expect(find.text('OptiZenqor Social'), findsOneWidget);
  });
}
