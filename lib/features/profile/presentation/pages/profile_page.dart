import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return MitraScaffold(
            title: 'Profil',
            activeIndex: 4,
            onRefresh: context.read<ProfileCubit>().load,
            child: switch (state) {
              ProfileLoading() || ProfileInitial() =>
                const CardSkeleton(height: 180),
              ProfileError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<ProfileCubit>().load,
              ),
              ProfileLoaded(:final profile) => MedicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(profile.email),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Telepon: ${profile.phone}'),
                    Text('Profesi: ${profile.profession}'),
                    Text('Verifikasi: ${profile.verificationStatus}'),
                    Text('Lokasi: ${profile.workLocation}'),
                  ],
                ),
              ),
              _ => const ErrorCard(message: 'State profil tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}
