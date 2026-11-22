import '../models/protocol.dart';

/// Deterministic triage for a versioned protocol.
///
/// Red findings short-circuit immediately; amber is only reported once every
/// question has been answered; otherwise the screening is still incomplete.
Evaluation evaluate(Protocol protocol, Map<String, bool> answers) {
  final findings = protocol.questions.where((q) => answers[q.id] == true).toList();
  final unanswered =
      protocol.questions.where((q) => !answers.containsKey(q.id)).toList();
  final total = protocol.questions.length;
  final answered = total - unanswered.length;

  CompleteEvaluation complete(Risk risk) {
    final terminal = protocol.terminals[risk]!;
    return CompleteEvaluation(
      risk: risk,
      terminal: terminal,
      protocolRef: protocol.refFor(terminal),
      answered: answered,
      total: total,
      findings: findings,
    );
  }

  if (findings.any((f) => f.isRed)) return complete(Risk.red);
  if (unanswered.isEmpty) {
    return complete(findings.any((f) => !f.isRed) ? Risk.amber : Risk.green);
  }
  return IncompleteEvaluation(
    nextQuestion: unanswered.first,
    answered: answered,
    total: total,
    findings: findings,
  );
}
