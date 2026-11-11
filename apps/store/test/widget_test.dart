import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store/flavors.dart';
import 'package:store/pages/my_home_page.dart';

void main() {
  // F.appFlavor is `late final`, so it can only be assigned once per test file.
  setUpAll(() => F.appFlavor = Flavor.dev);

  testWidgets('home page shows the flavor title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AuraTheme.light(), home: const MyHomePage()),
    );

    expect(find.text('Hello (DEV) Aura'), findsOneWidget);
  });
}
