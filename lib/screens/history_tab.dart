import 'package:material_ui/material_ui.dart';

import '../models/case_record.dart';
import '../storage/case_store.dart';
import '../theme.dart';
import '../widgets/case_tile.dart';
import 'slip_preview_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.store,
    required this.onStartScreening,
  });

  final CaseStore store;
  final VoidCallback onStartScreening;

  Future<void> _confirmDelete(BuildContext context, CaseRecord record) async {
    final name = record.patientName.trim().isEmpty
        ? 'Unnamed patient'
        : record.patientName.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete this referral?'),
        content: Text('$name · ${record.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await store.remove(record.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral deleted')),
    );
  }

  Future<void> _confirmClear(BuildContext context, int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Clear all referrals?'),
        content: Text(
          'This deletes $count saved ${count == 1 ? 'referral' : 'referrals'} from this device. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await store.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All referrals cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final cases = store.cases;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Referrals', style: sectionTitle),
                      ),
                      if (cases.isNotEmpty)
                        TextButton(
                          onPressed: () => _confirmClear(context, cases.length),
                          child: const Text('Clear all'),
                        ),
                    ],
                  ),
                  Text(
                    cases.isEmpty
                        ? 'Saved locally on this device.'
                        : '${cases.length} saved · on this device only',
                    style: bodyMuted,
                  ),
                  const SizedBox(height: 20),
                  if (cases.isEmpty)
                    _EmptyState(onStartScreening: onStartScreening)
                  else
                    ...cases.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CaseTile(
                          record: record,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    SlipPreviewScreen(record: record),
                              ),
                            );
                          },
                          onDelete: () => _confirmDelete(context, record),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStartScreening});

  final VoidCallback onStartScreening;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.pineSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.pine,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No referrals yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'A red or amber screening can generate a printable referral slip.',
            textAlign: TextAlign.center,
            style: bodyMuted,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onStartScreening,
            child: const Text('Start a screening'),
          ),
        ],
      ),
    );
  }
}
