import 'package:flutter_test/flutter_test.dart';
import 'package:sahayak/models/case_record.dart';
import 'package:sahayak/models/protocol.dart';
import 'package:sahayak/storage/case_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

CaseRecord sample({
  String id = 'SY-ABC123',
  DateTime? at,
  String name = 'R. Devi',
}) {
  return CaseRecord(
    id: id,
    createdAt: at ?? DateTime(2026, 11, 22, 10, 20),
    risk: Risk.red,
    badge: 'RED',
    title: 'Refer immediately',
    action: 'Do not wait for the next routine visit.',
    steps: const [
      'Arrange transport to the nearest PHC or FRU now.',
      'Generate the referral slip before leaving.',
    ],
    findings: const ['heavy bleeding'],
    protocolRef: 'maternal-danger-signs@1.0.0#emergency_referral',
    patientName: name,
    patientAge: '27',
    village: 'Kothur',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves cases and reloads them from storage', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = CaseStore(prefs);
    await store.load();
    expect(store.cases, isEmpty);

    await store.add(sample());

    final reloaded = CaseStore(prefs);
    await reloaded.load();
    expect(reloaded.cases, hasLength(1));
    expect(reloaded.cases.single.id, 'SY-ABC123');
    expect(reloaded.cases.single.risk, Risk.red);
    expect(reloaded.cases.single.findings, ['heavy bleeding']);
    expect(reloaded.cases.single.village, 'Kothur');
  });

  test('keeps the newest referral first', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = CaseStore(prefs);
    await store.load();

    await store.add(sample(id: 'SY-OLD001', at: DateTime(2026, 11, 20)));
    await store.add(sample(id: 'SY-NEW001', at: DateTime(2026, 11, 22)));

    expect(store.cases.first.id, 'SY-NEW001');
    expect(store.cases.last.id, 'SY-OLD001');
  });

  test('removes a single case and clears all cases', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = CaseStore(prefs);
    await store.load();
    await store.add(sample(id: 'SY-ONE001'));
    await store.add(sample(id: 'SY-TWO002'));

    await store.remove('SY-ONE001');
    expect(store.cases.map((c) => c.id), ['SY-TWO002']);

    await store.clear();
    expect(store.cases, isEmpty);

    final reloaded = CaseStore(prefs);
    await reloaded.load();
    expect(reloaded.cases, isEmpty);
  });

  test('case ids follow the SY-XXXXXX format', () {
    final id = CaseRecord.newId(DateTime(2026, 11, 22, 10, 20));
    expect(id, matches(RegExp(r'^SY-[0-9A-Z]{6}$')));
  });
}
