import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/screens/common/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrapWithApp() {
  return MaterialApp(
    home: const HomeScreen(),
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(body: Text('route:${settings.name}')),
    ),
  );
}

Future<void> _pumpHomeScreen(WidgetTester tester, {bool? isActive}) async {
  final Map<String, Object> prefs = {};
  if (isActive != null) prefs['isActive'] = isActive;
  SharedPreferences.setMockInitialValues(prefs);

  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_wrapWithApp());
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen — inactive account tile restriction', () {
    testWidgets('an unrestricted tile (Branches) shows the Account Inactive dialog when isActive is false', (tester) async {
      await _pumpHomeScreen(tester, isActive: false);

      await tester.tap(find.text('Branches'));
      await tester.pumpAndSettle();

      expect(find.text('Account Inactive'), findsOneWidget);
      expect(find.text('Please renew Membership or Contact Admin'), findsOneWidget);
      expect(find.textContaining('Okay'), findsOneWidget);
      expect(find.textContaining('route:'), findsNothing);
    });

    testWidgets('the dialog dismisses on tapping the Okay button', (tester) async {
      await _pumpHomeScreen(tester, isActive: false);

      await tester.tap(find.text('My Trainer'));
      await tester.pumpAndSettle();
      expect(find.text('Account Inactive'), findsOneWidget);

      await tester.tap(find.textContaining('Okay'));
      await tester.pumpAndSettle();
      expect(find.text('Account Inactive'), findsNothing);
    });

    testWidgets('My Records & Details stays tappable when isActive is false', (tester) async {
      await _pumpHomeScreen(tester, isActive: false);

      await tester.tap(find.text('My Records & Details'));
      await tester.pumpAndSettle();

      expect(find.text('Account Inactive'), findsNothing);
      expect(find.textContaining('route:'), findsOneWidget);
    });

    testWidgets('My Grievances stays tappable when isActive is false', (tester) async {
      await _pumpHomeScreen(tester, isActive: false);

      await tester.tap(find.text('My Grievances'));
      await tester.pumpAndSettle();

      expect(find.text('Account Inactive'), findsNothing);
      expect(find.textContaining('route:'), findsOneWidget);
    });

    testWidgets('every tile is tappable when isActive is true', (tester) async {
      await _pumpHomeScreen(tester, isActive: true);

      await tester.tap(find.text('Branches'));
      await tester.pumpAndSettle();

      expect(find.text('Account Inactive'), findsNothing);
      expect(find.textContaining('route:'), findsOneWidget);
    });

    testWidgets('a missing isActive value (null) fails open — tiles stay tappable', (tester) async {
      await _pumpHomeScreen(tester, isActive: null);

      await tester.tap(find.text('My Posture Training'));
      await tester.pumpAndSettle();

      expect(find.text('Account Inactive'), findsNothing);
      expect(find.textContaining('route:'), findsOneWidget);
    });
  });
}