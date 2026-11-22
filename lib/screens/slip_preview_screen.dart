import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';

import '../models/case_record.dart';
import '../pdf/save_pdf.dart';
import '../pdf/slip_pdf.dart';
import '../theme.dart';
import '../widgets/brand.dart';

class SlipPreviewScreen extends StatefulWidget {
  const SlipPreviewScreen({super.key, required this.record});

  final CaseRecord record;

  @override
  State<SlipPreviewScreen> createState() => _SlipPreviewScreenState();
}

class _SlipPreviewScreenState extends State<SlipPreviewScreen> {
  late final Future<Uint8List> _pdf = buildSlipPdf(widget.record);
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not finish that action: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _savePdf() => _run(() async {
        final name = await savePdf(
          await _pdf,
          'sahayak-${widget.record.id.toLowerCase()}.pdf',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved $name')),
        );
      });

  Future<void> _print() => _run(() async {
        await Printing.layoutPdf(
          name: 'Sahayak ${widget.record.id}',
          onLayout: (_) => _pdf,
        );
      });

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final issued = DateFormat('d MMM y, h:mm a').format(record.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Referral slip'),
            Text(record.id, style: refStyle.copyWith(fontSize: 11)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const BrandMark(size: 28),
                          const SizedBox(width: 9),
                          const Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sahayak',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'REFERRAL SLIP',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    letterSpacing: 1.6,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  record.id,
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: refStyle.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  issued,
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final nameField = _PaperField(
                            label: 'PATIENT NAME OR ID',
                            value: record.patientName,
                          );
                          final ageField = _PaperField(
                            label: 'AGE',
                            value: record.patientAge,
                          );
                          final villageField = _PaperField(
                            label: 'VILLAGE',
                            value: record.village,
                          );
                          if (constraints.maxWidth < 430) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                nameField,
                                const SizedBox(height: 14),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 1, child: ageField),
                                    const SizedBox(width: 14),
                                    Expanded(flex: 2, child: villageField),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: nameField),
                              const SizedBox(width: 14),
                              Expanded(flex: 1, child: ageField),
                              const SizedBox(width: 14),
                              Expanded(flex: 2, child: villageField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: record.risk.soft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: record.risk.color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                RiskBadge(risk: record.risk),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    record.title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              record.action,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionLabel(text: 'Findings'),
                      const SizedBox(height: 6),
                      ...record.findings.map(
                        (finding) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '•  ',
                                style: TextStyle(fontSize: 12.5),
                              ),
                              Expanded(
                                child: Text(
                                  finding,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SectionLabel(text: 'Action'),
                      const SizedBox(height: 6),
                      ...record.steps.indexed.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 18,
                                child: Text(
                                  '${entry.$1 + 1}.',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.pine,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.$2,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final meta = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.protocolRef,
                                style: refStyle.copyWith(fontSize: 10),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Issued by ASHA-DEMO-01',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          );
                          final signature = Column(
                            children: [
                              Container(
                                width: 110,
                                height: 1,
                                color: AppColors.muted,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Signature',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          );
                          if (constraints.maxWidth < 430) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                meta,
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: signature,
                                ),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: meta),
                              signature,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Illustrative document generated by a demo. Not a medical record and not medical advice.',
                          style: TextStyle(
                            fontSize: 9.5,
                            height: 1.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This is the layout of the generated A4 PDF. Use Save PDF or Print below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.paper,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _savePdf,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Save PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _print,
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperField extends StatelessWidget {
  const _PaperField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final filled = value.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 3),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Text(
            filled ? value.trim() : '—',
            style: TextStyle(
              fontSize: 12.5,
              color: filled ? AppColors.ink : AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}
