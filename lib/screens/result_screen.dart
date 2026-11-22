import 'package:material_ui/material_ui.dart';

import '../models/protocol.dart';
import '../storage/case_store.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import 'screening_screen.dart';
import 'slip_form_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.protocol,
    required this.result,
    required this.store,
  });

  final Protocol protocol;
  final CompleteEvaluation result;
  final CaseStore store;

  @override
  Widget build(BuildContext context) {
    final risk = result.risk;
    final stoppedEarly = result.answered < result.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Triage result')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: risk.soft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: risk.color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RiskBadge(risk: risk, large: true),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              risk.title(),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result.terminal.title,
                        style: const TextStyle(
                          fontFamily: 'Fraunces',
                          fontSize: 30,
                          height: 1.1,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.terminal.action,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.55,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  stoppedEarly
                      ? 'Screened ${result.answered} of ${result.total} questions — stopped at the first red flag.'
                      : 'All ${result.total} questions answered.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                const SectionLabel(text: 'Findings'),
                const SizedBox(height: 8),
                if (result.findings.isEmpty)
                  const _FindingRow(text: 'No danger signs recorded.', green: true)
                else
                  ...result.findings.map(
                    (finding) => _FindingRow(text: finding.label),
                  ),
                const SizedBox(height: 20),
                const SectionLabel(text: 'Action'),
                const SizedBox(height: 8),
                ...result.terminal.steps.indexed.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            '${entry.$1 + 1}.',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.pine,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.$2,
                            style: const TextStyle(fontSize: 13.5, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(result.protocolRef, style: refStyle),
                ),
                const SizedBox(height: 24),
                if (risk != Risk.green)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SlipFormScreen(
                            protocol: protocol,
                            result: result,
                            store: store,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('Create referral slip'),
                  ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => ScreeningScreen(
                          protocol: protocol,
                          store: store,
                        ),
                      ),
                    );
                  },
                  child: const Text('Screen another'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to home'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Illustrative protocol excerpt. Not a medical device — clinical judgment always overrides this result.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on Risk {
  String title() => switch (this) {
        Risk.red => 'Immediate referral needed',
        Risk.amber => 'Same-day referral needed',
        Risk.green => 'Routine care',
      };
}

class _FindingRow extends StatelessWidget {
  const _FindingRow({required this.text, this.green = false});

  final String text;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            green ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: green ? AppColors.riskGreen : AppColors.riskRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
