import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sahayak/models/case_record.dart';
import 'package:sahayak/models/protocol.dart';
import 'package:sahayak/screens/slip_preview_screen.dart';
import 'package:sahayak/theme.dart';

final _record = CaseRecord(
  id: 'SY-TEST01',
  createdAt: DateTime(2026, 11, 22, 23, 3),
  risk: Risk.red,
  badge: 'RED',
  title: 'Refer immediately',
  action: 'Do not wait for the next routine visit.',
  steps: [
    'Arrange transport to the nearest PHC or FRU now.',
    'Do not wait for the next routine visit.',
  ],
  findings: ['heavy bleeding', 'convulsions'],
  protocolRef: 'maternal-danger-signs@1.0.0#emergency_referral',
  patientName: 'R. Devi',
  patientAge: '27',
  village: 'Kothur',
);

void main() {
  testWidgets('slip preview renders offline and fits a narrow phone',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: SlipPreviewScreen(record: _record),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('REFERRAL SLIP'), findsOneWidget);
    expect(find.text('Save PDF'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    expect(
      find.text('maternal-danger-signs@1.0.0#emergency_referral'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Signature'), 250);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
