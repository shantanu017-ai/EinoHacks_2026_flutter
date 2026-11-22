import 'package:flutter_test/flutter_test.dart';
import 'package:sahayak/data/maternal_protocol.dart';
import 'package:sahayak/engine/protocol_engine.dart';
import 'package:sahayak/models/protocol.dart';

Map<String, bool> allAnswered({Map<String, bool> overrides = const {}}) => {
      for (final question in maternalProtocol.questions) question.id: false,
      ...overrides,
    };

void main() {
  group('evaluate', () {
    test('asks the red-flag question first', () {
      final result = evaluate(maternalProtocol, {});

      expect(result, isA<IncompleteEvaluation>());
      final incomplete = result as IncompleteEvaluation;
      expect(incomplete.nextQuestion.id, 'danger_bleeding');
      expect(incomplete.answered, 0);
      expect(incomplete.total, 4);
    });

    test('red finding short-circuits immediately', () {
      final result = evaluate(maternalProtocol, {'danger_bleeding': true});

      expect(result, isA<CompleteEvaluation>());
      final complete = result as CompleteEvaluation;
      expect(complete.risk, Risk.red);
      expect(complete.terminal.id, 'emergency_referral');
      expect(complete.answered, 1);
      expect(
        complete.protocolRef,
        'maternal-danger-signs@1.0.0#emergency_referral',
      );
    });

    test('amber finding waits for the remaining answers', () {
      final result = evaluate(maternalProtocol, {'severe_headache': true});

      expect(result, isA<IncompleteEvaluation>());
      final incomplete = result as IncompleteEvaluation;
      expect(incomplete.answered, 1);
      expect(incomplete.findings.single.id, 'severe_headache');
      expect(incomplete.nextQuestion.id, 'danger_bleeding');
    });

    test('amber result once every question is answered', () {
      final result = evaluate(
        maternalProtocol,
        allAnswered(overrides: {'severe_headache': true}),
      ) as CompleteEvaluation;

      expect(result.risk, Risk.amber);
      expect(result.answered, 4);
      expect(result.protocolRef, 'maternal-danger-signs@1.0.0#same_day_referral');
    });

    test('red outranks amber even when both are present', () {
      final result = evaluate(
        maternalProtocol,
        allAnswered(
          overrides: {'convulsions': true, 'severe_headache': true},
        ),
      ) as CompleteEvaluation;

      expect(result.risk, Risk.red);
      expect(result.findings.length, 2);
    });

    test('all negative answers give routine care', () {
      final result =
          evaluate(maternalProtocol, allAnswered()) as CompleteEvaluation;

      expect(result.risk, Risk.green);
      expect(result.findings, isEmpty);
      expect(result.protocolRef, 'maternal-danger-signs@1.0.0#routine_care');
    });

    test('unknown answer keys are ignored', () {
      final result =
          evaluate(maternalProtocol, {'not_a_question': true});

      expect(result, isA<IncompleteEvaluation>());
      final incomplete = result as IncompleteEvaluation;
      expect(incomplete.answered, 0);
      expect(incomplete.nextQuestion.id, 'danger_bleeding');
    });

    test('protocolRef stamps id, version and terminal', () {
      final terminal = maternalProtocol.terminals[Risk.amber]!;
      expect(
        maternalProtocol.refFor(terminal),
        'maternal-danger-signs@1.0.0#same_day_referral',
      );
    });
  });
}
