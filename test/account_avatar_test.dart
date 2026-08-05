import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/theme/app_theme.dart';
import 'package:nutriflow_mobile/shared/widgets/account_menu.dart';

Widget _host(Widget child) => MaterialApp(
      theme: NutriFlowTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('AccountAvatar', () {
    testWidgets('falls back to the first letter when there is no image', (tester) async {
      await tester.pumpWidget(_host(const AccountAvatar(imageUrl: null, name: 'oscar')));
      expect(find.text('O'), findsOneWidget);
    });

    testWidgets('falls back to a placeholder rather than blank on an empty name', (tester) async {
      await tester.pumpWidget(_host(const AccountAvatar(imageUrl: '', name: '   ')));
      expect(find.text('?'), findsOneWidget);
    });
  });
}
