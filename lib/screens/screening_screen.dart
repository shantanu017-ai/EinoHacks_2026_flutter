import 'package:material_ui/material_ui.dart';

import '../engine/protocol_engine.dart';
import '../models/protocol.dart';
import '../storage/case_store.dart';
import '../theme.dart';
import 'result_screen.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({
    super.key,
    required this.protocol,
    required this.store,
  });

  final Protocol protocol;
  final CaseStore store;

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  Map<String, bool> _answers = {};
  Question? _lastQuestion;
  bool? _lastValue;
  bool _leaving = false;

  Evaluation get _evaluation => evaluate(widget.protocol, _answers);

  void _answer(bool value) {
    if (_leaving) return;
    final current = _evaluation;
    if (current is! IncompleteEvaluation) return;

    final updated = Map<String, bool>.from(_answers)
      ..[current.nextQuestion.id] = value;
    final next = evaluate(widget.protocol, updated);

    setState(() {
      _answers = updated;
      _lastQuestion = current.nextQuestion;
      _lastValue = value;
    });

    if (next is CompleteEvaluation) {
      _leaving = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            protocol: widget.protocol,
            result: next,
            store: widget.store,
          ),
        ),
      );
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Discard this screening?'),
        content: const Text(
          'Your answers on this screen will not be saved and no result will be generated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep screening'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final result = _evaluation;
    if (result is! IncompleteEvaluation) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final question = result.nextQuestion;
    final progress = result.answered / result.total;

    return PopScope(
      canPop: _answers.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.protocol.title),
              const SizedBox(height: 1),
              Text(
                'Protocol ${widget.protocol.version}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Question ${result.answered + 1} of ${result.total}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.line,
                      color: AppColors.pine,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        question.isRed
                            ? const _FlagChip(
                                text: 'RED-FLAG QUESTION',
                                color: AppColors.riskRed,
                                soft: Color(0xFFFBEDEC),
                              )
                            : const _FlagChip(
                                text: 'AMBER QUESTION',
                                color: AppColors.riskAmber,
                                soft: Color(0xFFFDF5E4),
                              ),
                        const SizedBox(height: 16),
                        Text(question.hi, style: hindiQuestion),
                        const SizedBox(height: 10),
                        Text(
                          question.en,
                          style: bodyMuted.copyWith(fontSize: 14.5),
                        ),
                        if (_lastQuestion != null && _lastValue != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pineSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 15,
                                  color: AppColors.pine,
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    'Recorded: ${_lastQuestion!.label} = '
                                    '${_lastValue! ? 'yes' : 'no'}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.pine,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _answer(true),
                                child: const Text('Yes'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _answer(false),
                                child: const Text('No'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 15,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'A red answer stops the screening at once. Every result carries its protocol reference.',
                          style: bodyMuted.copyWith(fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
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

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.text,
    required this.color,
    required this.soft,
  });

  final String text;
  final Color color;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: color,
        ),
      ),
    );
  }
}
