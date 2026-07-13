import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../cubit/tracking_cubit.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TrackingCubit>()..load(),
      child: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          return MitraScaffold(
            title: 'Tracking',
            activeIndex: 1,
            onRefresh: context.read<TrackingCubit>().load,
            child: switch (state) {
              TrackingLoading() || TrackingInitial() =>
                const CardSkeleton(height: 180),
              TrackingError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<TrackingCubit>().load,
              ),
              TrackingLoaded(:final tracking) => MedicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tracking.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(tracking.patientName),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Status: ${tracking.status}'),
                    Text('ETA: ${tracking.etaMinutes} menit'),
                    Text('Jarak: ${tracking.distanceKm} km'),
                  ],
                ),
              ),
              _ => const ErrorCard(message: 'State tracking tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}
