import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahayak/models/case_record.dart';
import 'package:sahayak/models/protocol.dart';
import 'package:sahayak/pdf/slip_pdf.dart';

void main() {
  test('builds a single-page PDF referral slip', () async {
    final record = CaseRecord(
      id: 'SY-TEST01',
      createdAt: DateTime(2026, 11, 22, 10, 20),
      risk: Risk.red,
      badge: 'RED',
      title: 'Refer immediately',
      action:
          'Do not wait for the next routine visit. Arrange transport to the nearest PHC or FRU now.',
      steps: const [
        'Arrange transport to the nearest PHC or FRU now.',
        'Do not wait for the next routine visit.',
        'Generate the referral slip before leaving.',
      ],
      findings: const ['heavy bleeding'],
      protocolRef: 'maternal-danger-signs@1.0.0#emergency_referral',
      patientName: 'R. Devi',
      patientAge: '27',
      village: 'Kothur',
    );

    final bytes = await buildSlipPdf(record);
    expect(bytes.length, greaterThan(5000));
    expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');

    final raw = latin1.decode(bytes, allowInvalid: true);
    expect(RegExp(r'/Type\s*/Page[^s]').allMatches(raw).length, 1);

    final out = File('preview/slip-sample.pdf');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(bytes);
  });
}
