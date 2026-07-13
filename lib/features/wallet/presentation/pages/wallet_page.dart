import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../cubit/wallet_cubit.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletCubit>()..load(),
      child: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return MitraScaffold(
            title: 'Wallet',
            activeIndex: 2,
            onRefresh: context.read<WalletCubit>().load,
            child: switch (state) {
              WalletLoading() || WalletInitial() => const _Loading(),
              WalletError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<WalletCubit>().load,
              ),
              WalletLoaded(:final summary) => Column(
                children: [
                  _MetricCard(label: 'Saldo Mitra', value: summary.balance),
                  const SizedBox(height: AppSpacing.md),
                  _MetricCard(
                    label: 'Pendapatan Hari Ini',
                    value: summary.todayIncome,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MetricCard(label: 'Pending', value: summary.pendingIncome),
                ],
              ),
              _ => const ErrorCard(message: 'State wallet tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(formatCurrency(value), style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const CardSkeleton(height: 160);
  }
}
