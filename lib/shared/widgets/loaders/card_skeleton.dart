import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Container(
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.card),
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonLine(width: 128),
          const SizedBox(height: AppSpacing.lg),
          _SkeletonLine(width: double.infinity),
          const SizedBox(height: AppSpacing.sm),
          _SkeletonLine(width: 180),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}
