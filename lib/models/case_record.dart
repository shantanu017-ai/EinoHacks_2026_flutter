import 'protocol.dart';

class CaseRecord {
  const CaseRecord({
    required this.id,
    required this.createdAt,
    required this.risk,
    required this.badge,
    required this.title,
    required this.action,
    required this.steps,
    required this.findings,
    required this.protocolRef,
    required this.patientName,
    required this.patientAge,
    required this.village,
  });

  final String id;
  final DateTime createdAt;
  final Risk risk;
  final String badge;
  final String title;
  final String action;
  final List<String> steps;
  final List<String> findings;
  final String protocolRef;
  final String patientName;
  final String patientAge;
  final String village;

  static String newId(DateTime at) {
    final raw = at.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final tail = raw.length > 6 ? raw.substring(raw.length - 6) : raw;
    return 'SY-${tail.padLeft(6, '0')}';
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'risk': risk.name,
        'badge': badge,
        'title': title,
        'action': action,
        'steps': steps,
        'findings': findings,
        'protocolRef': protocolRef,
        'patientName': patientName,
        'patientAge': patientAge,
        'village': village,
      };

  factory CaseRecord.fromJson(Map<String, dynamic> json) => CaseRecord(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        risk: Risk.values.firstWhere(
          (r) => r.name == json['risk'],
          orElse: () => Risk.green,
        ),
        badge: json['badge'] as String? ?? '',
        title: json['title'] as String? ?? '',
        action: json['action'] as String? ?? '',
        steps: (json['steps'] as List<dynamic>? ?? const []).cast<String>(),
        findings:
            (json['findings'] as List<dynamic>? ?? const []).cast<String>(),
        protocolRef: json['protocolRef'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        patientAge: json['patientAge'] as String? ?? '',
        village: json['village'] as String? ?? '',
      );
}
