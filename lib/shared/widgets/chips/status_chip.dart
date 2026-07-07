import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions/medical_status_colors.dart';

enum OrderStatus { requested, accepted, onTheWay, treatment, completed, cancelled }

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final extension = Theme.of(context).extension<MedicalStatusColors>()!;
    final (label, color) = switch (status) {
      OrderStatus.requested => ('Requested', extension.info),
      OrderStatus.accepted => ('Accepted', extension.success),
      OrderStatus.onTheWay => ('On The Way', extension.warning),
      OrderStatus.treatment => ('Treatment', extension.info),
      OrderStatus.completed => ('Completed', extension.available),
      OrderStatus.cancelled => ('Cancelled', Theme.of(context).colorScheme.error),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
