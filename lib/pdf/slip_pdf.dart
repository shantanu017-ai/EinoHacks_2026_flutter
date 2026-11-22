import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/case_record.dart';

const _pine = PdfColor.fromInt(0xFF0F433B);
const _pineDeep = PdfColor.fromInt(0xFF0B352F);
const _ink = PdfColor.fromInt(0xFF17211C);
const _muted = PdfColor.fromInt(0xFF5B6660);
const _line = PdfColor.fromInt(0xFFE4DFD3);
const _paper = PdfColor.fromInt(0xFFFAF7F0);
const _riskRed = PdfColor.fromInt(0xFFB4232A);
const _riskAmber = PdfColor.fromInt(0xFFA16207);
const _riskGreen = PdfColor.fromInt(0xFF17795E);

PdfColor _riskColor(CaseRecord r) => switch (r.risk.name) {
      'red' => _riskRed,
      'amber' => _riskAmber,
      _ => _riskGreen,
    };

PdfColor _riskSoft(CaseRecord r) => switch (r.risk.name) {
      'red' => PdfColor.fromInt(0xFFFBEDEC),
      'amber' => PdfColor.fromInt(0xFFFDF5E4),
      _ => PdfColor.fromInt(0xFFEAF4F0),
    };

Future<Uint8List> buildSlipPdf(CaseRecord record) async {
  final doc = pw.Document(
    title: 'Referral slip ${record.id}',
    author: 'Sahayak',
    subject: 'Frontline referral · ${record.protocolRef}',
  );

  final issued = DateFormat('d MMM y, h:mm a').format(record.createdAt);
  final issuedBy = record.protocolRef.contains('maternal-danger-signs')
      ? 'ASHA-DEMO-01'
      : 'ASHA-DEMO-01';

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 30,
              height: 30,
              decoration: pw.BoxDecoration(
                color: _pine,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                '+',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Sahayak',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'REFERRAL SLIP',
                  style: pw.TextStyle(
                    fontSize: 7,
                    letterSpacing: 1.6,
                    color: _muted,
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  record.id,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _pine,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  issued,
                  style: const pw.TextStyle(fontSize: 8, color: _muted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Divider(color: _line, thickness: 1),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: _field('PATIENT NAME OR ID', record.patientName),
            ),
            pw.SizedBox(width: 18),
            pw.Expanded(flex: 1, child: _field('AGE', record.patientAge)),
            pw.SizedBox(width: 18),
            pw.Expanded(flex: 2, child: _field('VILLAGE', record.village)),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: _riskSoft(record),
            border: pw.Border.all(color: _riskColor(record), width: 0.7),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _riskColor(record),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      record.badge,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    record.title,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 7),
              pw.Text(
                record.action,
                style: const pw.TextStyle(
                  fontSize: 9.5,
                  lineSpacing: 2.5,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _label('FINDINGS'),
        pw.SizedBox(height: 5),
        ...record.findings.map(
          (f) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('-  ', style: const pw.TextStyle(fontSize: 9.5)),
                pw.Expanded(
                  child: pw.Text(
                    f,
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        _label('ACTION'),
        pw.SizedBox(height: 5),
        ...record.steps.indexed.map(
          (entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${entry.$1 + 1}.  ',
                  style: const pw.TextStyle(fontSize: 9.5, color: _pine),
                ),
                pw.Expanded(
                  child: pw.Text(
                    entry.$2,
                    style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(color: _line, thickness: 0.7),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    record.protocolRef,
                    style: pw.TextStyle(
                      fontSize: 7.5,
                      color: _pineDeep,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Issued by $issuedBy',
                    style: const pw.TextStyle(fontSize: 7.5, color: _muted),
                  ),
                ],
              ),
            ),
            pw.Column(
              children: [
                pw.Container(width: 110, height: 0.7, color: _muted),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Signature',
                  style: const pw.TextStyle(fontSize: 7.5, color: _muted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: _paper,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'Illustrative document generated by a demo. Not a medical record and not medical advice. '
            'Clinical judgment always overrides this slip.',
            style: const pw.TextStyle(fontSize: 7, color: _muted),
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _field(String label, String value) {
  final filled = value.trim().isNotEmpty;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _label(label),
      pw.SizedBox(height: 6),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.only(bottom: 3),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _line, width: 0.8)),
        ),
        child: pw.Text(
          filled ? value.trim() : '—',
          style: pw.TextStyle(
            fontSize: 10,
            color: filled ? _ink : _muted,
          ),
        ),
      ),
    ],
  );
}

pw.Widget _label(String text) => pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 7,
        letterSpacing: 1.2,
        fontWeight: pw.FontWeight.bold,
        color: _muted,
      ),
    );
