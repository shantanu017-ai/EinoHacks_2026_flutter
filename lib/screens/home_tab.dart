import 'package:material_ui/material_ui.dart';

import '../storage/case_store.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/case_tile.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.store,
    required this.onStartScreening,
    required this.onOpenHistory,
  });

  final CaseStore store;
  final VoidCallback onStartScreening;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final recent = store.cases.take(2).toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  const _Header(),
                  const SizedBox(height: 28),
                  _Hero(onStartScreening: onStartScreening),
                  const SizedBox(height: 22),
                  _ProtocolCard(),
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Recent referrals', style: sectionTitle),
                        ),
                        TextButton(
                          onPressed: onOpenHistory,
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    ...recent.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CaseTile(record: record, onTap: onOpenHistory),
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  const Text('How it works', style: sectionTitle),
                  const SizedBox(height: 14),
                  const _Step(
                    number: '01',
                    title: 'Ask',
                    body:
                        'One danger-sign question at a time, in Hindi with an English gloss.',
                  ),
                  const _Step(
                    number: '02',
                    title: 'Decide',
                    body:
                        'A deterministic engine applies the protocol version. No model in the loop.',
                  ),
                  const _Step(
                    number: '03',
                    title: 'Hand off',
                    body:
                        'A printable referral slip carries the findings and the protocol reference.',
                  ),
                  const SizedBox(height: 22),
                  const _SafetyNote(),
                  const SizedBox(height: 20),
                  const Text(
                    'Illustrative excerpt — not a medical device. Decision support only.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BrandMark(),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sahayak',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'ASHA COPILOT',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.7,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onStartScreening});

  final VoidCallback onStartScreening;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.pineSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.pine.withValues(alpha: 0.16)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(),
              SizedBox(width: 7),
              Text(
                'DECISION-SUPPORT PROTOTYPE · 2026',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: AppColors.pine,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Protocol in\nevery pocket.', style: displayStyle),
        const Text('No signal required.', style: displayItalic),
        const SizedBox(height: 16),
        const Text(
          "Sahayak turns national protocol into a guided screening that works on a basic phone, in the worker's own language, without a data-entry form.",
          style: bodyMuted,
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(icon: Icons.wifi_off_rounded, label: 'Runs offline'),
            _Pill(icon: Icons.translate_rounded, label: 'Hindi + English'),
            _Pill(icon: Icons.alt_route_rounded, label: 'Deterministic'),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final primary = FilledButton.icon(
              onPressed: onStartScreening,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Start screening'),
            );
            final secondary = OutlinedButton(
              onPressed: () => _showHowItWorks(context),
              child: const Text('How it works'),
            );
            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  primary,
                  const SizedBox(height: 10),
                  secondary,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: primary),
                const SizedBox(width: 10),
                Expanded(child: secondary),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showHowItWorks(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('How a screening runs', style: sectionTitle),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogPoint(
                title: 'Protocol first',
                body:
                    'Questions and actions come from a versioned protocol file, not from a language model.',
              ),
              _DialogPoint(
                title: 'Red flags short-circuit',
                body:
                    'A red answer ends the screening immediately and points to emergency referral.',
              ),
              _DialogPoint(
                title: 'Amber needs all answers',
                body:
                    'An amber finding is only reported after every question has been answered.',
              ),
              _DialogPoint(
                title: 'Green means routine care',
                body:
                    'No danger signs means continue routine antenatal care and counsel the family.',
              ),
              _DialogPoint(
                title: 'Everything stamps a reference',
                body:
                    'Each result carries its protocol reference, and each referral slip carries a case ID.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(color: AppColors.pine, shape: BoxShape.circle),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.pine),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pine,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  size: 19,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Maternal danger signs',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 24,
              height: 1.1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Four danger-sign questions. Red flags stop the screening immediately.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RiskChip(color: Color(0xFFF0A3A6), label: 'RED · Refer now'),
              _RiskChip(color: Color(0xFFE8C07A), label: 'AMBER · Refer today'),
              _RiskChip(color: Color(0xFF8FD6C3), label: 'GREEN · Routine care'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Red and amber results generate a printable referral slip.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 15,
                color: AppColors.saffron,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: bodyMuted.copyWith(fontSize: 13.5)),
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pineSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, size: 18, color: AppColors.pine),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No network. No account.',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  'Screening runs on-device. Referral records stay in local storage on this phone and are never uploaded.',
                  style: bodyMuted.copyWith(fontSize: 12.5, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogPoint extends StatelessWidget {
  const _DialogPoint({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(body, style: bodyMuted.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
