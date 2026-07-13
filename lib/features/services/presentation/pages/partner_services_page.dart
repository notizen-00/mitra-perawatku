import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../cubit/partner_services_cubit.dart';

class PartnerServicesPage extends StatelessWidget {
  const PartnerServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PartnerServicesCubit>()..load(),
      child: BlocBuilder<PartnerServicesCubit, PartnerServicesState>(
        builder: (context, state) {
          return MitraScaffold(
            title: 'Layanan',
            activeIndex: 3,
            onRefresh: context.read<PartnerServicesCubit>().load,
            child: switch (state) {
              PartnerServicesLoading() || PartnerServicesInitial() =>
                const CardSkeleton(height: 140),
              PartnerServicesError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<PartnerServicesCubit>().load,
              ),
              PartnerServicesLoaded(:final services) when services.isEmpty =>
                const MedicalCard(child: Text('Belum ada layanan diajukan')),
              PartnerServicesLoaded(:final services) => Column(
                children: [
                  for (final service in services)
                    MedicalCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Radius: ${service.radiusKm} km'),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Status: ${service.isActive ? 'Aktif' : 'Nonaktif'} / '
                            '${service.isVerified ? 'Terverifikasi' : 'Menunggu'}',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              _ => const ErrorCard(message: 'State layanan tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}
