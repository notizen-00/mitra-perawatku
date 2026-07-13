import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../cubit/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..load(),
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          return MitraScaffold(
            title: 'Orders',
            activeIndex: 1,
            onRefresh: context.read<OrdersCubit>().load,
            child: switch (state) {
              OrdersLoading() || OrdersInitial() => const _Loading(),
              OrdersError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<OrdersCubit>().load,
              ),
              OrdersLoaded(:final orders) when orders.isEmpty =>
                const MedicalCard(child: Text('Belum ada order')),
              OrdersLoaded(:final orders) => Column(
                children: [
                  for (final order in orders)
                    MedicalCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.code,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(order.serviceName),
                          const SizedBox(height: AppSpacing.sm),
                          Text('${order.patientName} - ${order.status}'),
                          const SizedBox(height: AppSpacing.sm),
                          Text(formatCurrency(order.totalAmount)),
                        ],
                      ),
                    ),
                ],
              ),
              _ => const ErrorCard(message: 'State orders tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CardSkeleton(height: 120),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 120),
      ],
    );
  }
}
