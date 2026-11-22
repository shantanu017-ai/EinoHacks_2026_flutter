enum Risk { green, amber, red }

class Question {
  const Question({
    required this.id,
    required this.hi,
    required this.en,
    required this.label,
    required this.isRed,
  });

  final String id;
  final String hi;
  final String en;
  final String label;
  final bool isRed;
}

class Terminal {
  const Terminal({
    required this.id,
    required this.risk,
    required this.badge,
    required this.title,
    required this.action,
    required this.steps,
  });

  final String id;
  final Risk risk;
  final String badge;
  final String title;
  final String action;
  final List<String> steps;
}

class Protocol {
  const Protocol({
    required this.id,
    required this.title,
    required this.version,
    required this.source,
    required this.questions,
    required this.terminals,
  });

  final String id;
  final String title;
  final String version;
  final String source;
  final List<Question> questions;
  final Map<Risk, Terminal> terminals;

  String refFor(Terminal terminal) => '$id@$version#${terminal.id}';
}

sealed class Evaluation {
  const Evaluation({
    required this.answered,
    required this.total,
    required this.findings,
  });

  final int answered;
  final int total;
  final List<Question> findings;
}

class IncompleteEvaluation extends Evaluation {
  const IncompleteEvaluation({
    required this.nextQuestion,
    required super.answered,
    required super.total,
    required super.findings,
  });

  final Question nextQuestion;
}

class CompleteEvaluation extends Evaluation {
  const CompleteEvaluation({
    required this.risk,
    required this.terminal,
    required this.protocolRef,
    required super.answered,
    required super.total,
    required super.findings,
  });

  final Risk risk;
  final Terminal terminal;
  final String protocolRef;
}
