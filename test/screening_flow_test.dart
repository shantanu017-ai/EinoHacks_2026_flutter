import 'package:flutter_test/flutter_test.dart';
import 'package:sahayak/main.dart';
import 'package:sahayak/storage/case_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<CaseStore> emptyStore() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final store = CaseStore(prefs);
  await store.load();
  return store;
}

void main() {
  testWidgets('red answer stops the screening at the first question',
      (tester) async {
    final store = await emptyStore();
    await tester.pumpWidget(SahayakApp(store: store));

    expect(find.text('Protocol in\nevery pocket.'), findsOneWidget);

    await tester.tap(find.text('Start screening'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 4'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('Refer immediately'), findsOneWidget);
    expect(
      find.text('maternal-danger-signs@1.0.0#emergency_referral'),
      findsOneWidget,
    );
    expect(find.textContaining('Screened 1 of 4'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Create referral slip'),
      300,
    );
    expect(find.text('Create referral slip'), findsOneWidget);
  });

  testWidgets('all four No answers reach routine care', (tester) async {
    final store = await emptyStore();
    await tester.pumpWidget(SahayakApp(store: store));

    await tester.tap(find.text('Start screening'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 4; i++) {
      expect(find.text('No'), findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Continue routine care'), findsOneWidget);
    expect(
      find.text('maternal-danger-signs@1.0.0#routine_care'),
      findsOneWidget,
    );
  });

  testWidgets('amber finding needs every answer before it reports',
      (tester) async {
    final store = await emptyStore();
    await tester.pumpWidget(SahayakApp(store: store));

    await tester.tap(find.text('Start screening'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('Question 4 of 4'), findsOneWidget);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(find.text('Refer today'), findsOneWidget);
    expect(
      find.text('maternal-danger-signs@1.0.0#same_day_referral'),
      findsOneWidget,
    );
  });
}
