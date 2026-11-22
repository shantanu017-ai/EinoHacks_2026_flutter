import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../models/case_record.dart';
import '../theme.dart';
import 'brand.dart';

class CaseTile extends StatelessWidget {
  const CaseTile({
    super.key,
    required this.record,
    this.onTap,
    this.onDelete,
  });

  final CaseRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM y · h:mm a').format(record.createdAt);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 46,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  color: record.risk.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RiskBadge(risk: record.risk),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            record.patientName.trim().isEmpty
                                ? 'Unnamed patient'
                                : record.patientName.trim(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (record.patientAge.trim().isNotEmpty)
                          '${record.patientAge.trim()} yrs',
                        if (record.village.trim().isNotEmpty)
                          record.village.trim(),
                        date,
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      record.protocolRef,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: refStyle,
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete referral',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
