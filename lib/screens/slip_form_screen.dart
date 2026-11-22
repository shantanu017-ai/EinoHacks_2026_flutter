import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/case_record.dart';
import '../models/protocol.dart';
import '../storage/case_store.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import 'slip_preview_screen.dart';

class SlipFormScreen extends StatefulWidget {
  const SlipFormScreen({
    super.key,
    required this.protocol,
    required this.result,
    required this.store,
  });

  final Protocol protocol;
  final CompleteEvaluation result;
  final CaseStore store;

  @override
  State<SlipFormScreen> createState() => _SlipFormScreenState();
}

class _SlipFormScreenState extends State<SlipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _village = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _village.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final now = DateTime.now();
    final record = CaseRecord(
      id: CaseRecord.newId(now),
      createdAt: now,
      risk: widget.result.risk,
      badge: widget.result.terminal.badge,
      title: widget.result.terminal.title,
      action: widget.result.terminal.action,
      steps: widget.result.terminal.steps,
      findings: widget.result.findings.map((f) => f.label).toList(),
      protocolRef: widget.result.protocolRef,
      patientName: _name.text.trim(),
      patientAge: _age.text.trim(),
      village: _village.text.trim(),
    );

    await widget.store.add(record);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SlipPreviewScreen(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final risk = widget.result.risk;
    return Scaffold(
      appBar: AppBar(title: const Text('Referral slip')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: risk.soft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: risk.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        RiskBadge(risk: risk),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.result.terminal.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Patient details', style: sectionTitle),
                  const SizedBox(height: 6),
                  const Text(
                    'These fields print on the slip. Nothing is uploaded.',
                    style: bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Patient name or ID',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(labelText: 'Age'),
                          validator: (value) {
                            final age = int.tryParse((value ?? '').trim());
                            if (age == null) return 'Enter an age';
                            if (age < 1 || age > 120) return '1–120 only';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _village,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Village (optional)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _generate,
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(
                      _submitting ? 'Generating…' : 'Generate referral slip',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'The slip is saved to Referrals on this device and stamped with '
                    '${widget.result.protocolRef}.',
                    style: bodyMuted.copyWith(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
