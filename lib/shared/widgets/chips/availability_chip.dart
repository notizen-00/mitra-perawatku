import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions/medical_status_colors.dart';

enum AvailabilityStatus { available, busy, offline }

class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({required this.status, super.key});

  final AvailabilityStatus status;

  @override
  Widget build(BuildContext context) {
    final extension = Theme.of(context).extension<MedicalStatusColors>()!;
    final (label, color) = switch (status) {
      AvailabilityStatus.available => ('Available', extension.available),
      AvailabilityStatus.busy => ('Busy', extension.busy),
      AvailabilityStatus.offline => ('Offline', extension.offline),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
