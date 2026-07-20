import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/chips/availability_chip.dart';
import '../../../../shared/widgets/chips/status_chip.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../orders/domain/entities/incoming_order.dart';
import '../../../orders/domain/usecases/accept_service_booking.dart';
import '../../../orders/domain/usecases/decline_service_booking.dart';
import '../../../orders/presentation/widgets/incoming_order_dialog.dart';
import '../../domain/entities/home_summary.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final isAvailable = state is HomeLoaded
                  ? state.summary.isAvailable
                  : false;
              final loading = state is HomeLoading || state is HomeInitial;
              return _AvailabilityToggle(
                isAvailable: isAvailable,
                onChanged: loading
                    ? null
                    : (value) => context.read<HomeCubit>().setAvailable(value),
              );
            },
          ),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final count = state is HomeLoaded
                  ? state.summary.unreadNotifications
                  : 0;
              return _NotificationButton(count: count);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: context.read<HomeCubit>().load,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const _DashboardSkeleton();
            }

            if (state is HomeError) {
              return ListView(
                padding: AppSpacing.screen,
                children: [
                  ErrorCard(
                    message: state.message,
                    onRetry: context.read<HomeCubit>().load,
                  ),
                ],
              );
            }

            final summary = (state as HomeLoaded).summary;
            return _DashboardContent(summary: summary);
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          final route = switch (index) {
            0 => '/dashboard',
            1 => '/orders',
            2 => '/wallet',
            3 => '/services',
            _ => '/profile',
          };
          context.go(route);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mobileMargin,
        AppSpacing.lg,
        AppSpacing.mobileMargin,
        AppSpacing.xl,
      ),
      children: [
        _PartnerHeader(summary: summary),
        const SizedBox(height: AppSpacing.md),
        _WalletOverview(summary: summary),
        const SizedBox(height: AppSpacing.md),
        _StatsGrid(summary: summary),
        const SizedBox(height: AppSpacing.md),
        _ActiveServiceCard(service: summary.activeService),
        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(
          title: 'Order Masuk',
          action: 'Lihat semua',
          onAction: () => context.go('/orders'),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final order in summary.incomingOrders) ...[
          _OrderCard(order: order),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.lg),
        const _SectionHeader(title: 'Jadwal Hari Ini'),
        const SizedBox(height: AppSpacing.md),
        _ScheduleList(items: summary.todaySchedules),
        const SizedBox(height: AppSpacing.lg),
        const _SectionHeader(title: 'Aktivitas Terbaru'),
        const SizedBox(height: AppSpacing.md),
        _ActivityList(items: summary.recentActivities),
      ],
    );
  }
}

class _PartnerHeader extends StatelessWidget {
  const _PartnerHeader({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MedicalCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colors.primaryContainer,
            backgroundImage: summary.profilePhotoUrl.isEmpty
                ? null
                : NetworkImage(summary.profilePhotoUrl),
            child: summary.profilePhotoUrl.isEmpty
                ? Icon(
                    Icons.medical_services_outlined,
                    color: colors.onPrimary,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.partnerName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary.profession,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AvailabilityChip(
                      status: summary.isAvailable
                          ? AvailabilityStatus.available
                          : AvailabilityStatus.offline,
                    ),
                    _VerificationChip(status: summary.verificationStatus),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletOverview extends StatelessWidget {
  const _WalletOverview({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Mitra',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: colors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatCurrency(summary.walletBalance),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: colors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _WalletMetric(
                    label: 'Hari ini',
                    value: _formatCurrency(summary.todayIncome),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _WalletMetric(
                    label: 'Pending',
                    value: _formatCurrency(summary.pendingIncome),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.onPrimary.withValues(alpha: 0.14),
        borderRadius: AppRadius.control,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: colors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 0.95,
      children: [
        _StatTile(
          icon: Icons.book_online_outlined,
          label: 'Aktif',
          value: '${summary.activeOrders}',
          color: Theme.of(context).colorScheme.secondary,
        ),
        _StatTile(
          icon: Icons.calendar_month_outlined,
          label: 'Hari ini',
          value: '${summary.todayOrders}',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        _StatTile(
          icon: Icons.star_rounded,
          label: 'Rating',
          value: summary.rating.toStringAsFixed(1),
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ActiveServiceCard extends StatelessWidget {
  const _ActiveServiceCard({required this.service});

  final ActiveService service;

  @override
  Widget build(BuildContext context) {
    final hasActiveService = service.status != 'idle';

    return MedicalCard(
      onTap: hasActiveService ? () => context.go('/tracking') : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Layanan Aktif',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (hasActiveService)
                StatusChip(status: _mapOrderStatus(service.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(service.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            service.patientName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (hasActiveService) ...[
                _InlineMetric(
                  icon: Icons.timer_outlined,
                  text: '${service.etaMinutes} menit',
                ),
                const SizedBox(width: AppSpacing.md),
                _InlineMetric(
                  icon: Icons.route_outlined,
                  text: '${service.distanceKm} km',
                ),
              ] else
                const _InlineMetric(
                  icon: Icons.hourglass_empty_rounded,
                  text: 'Tidak ada perjalanan aktif',
                ),
              const Spacer(),
              if (hasActiveService) const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      onTap: () => _showIncomingOrder(context, order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.patientName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      order.serviceName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              StatusChip(status: _mapOrderStatus(order.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _InlineMetric(
                icon: Icons.schedule_rounded,
                text: order.scheduledAt,
              ),
              _InlineMetric(
                icon: Icons.route_outlined,
                text: '${order.distanceKm} km',
              ),
              _InlineMetric(
                icon: Icons.payments_outlined,
                text: _formatCurrency(order.totalAmount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showIncomingOrder(
    BuildContext context,
    PartnerOrder order,
  ) async {
    final accepted = await showIncomingOrderDialog(
      context: context,
      order: IncomingOrder(
        id: order.id,
        code: order.bookingCode,
        serviceName: order.serviceName,
        patientName: order.patientName,
        scheduledAt: order.scheduledAt,
        totalAmount: order.totalAmount,
        paymentStatus: order.paymentStatus,
        addressLabel: order.addressLabel,
        addressText: order.addressText,
        latitude: order.latitude,
        longitude: order.longitude,
        distanceKm: order.distanceKm,
      ),
      onAccept: () => sl<AcceptServiceBooking>()(order.id),
      onDecline: () => sl<DeclineServiceBooking>()(order.id),
    );

    if (!context.mounted) return;
    if (accepted == true) {
      context.go('/orders/${order.id}');
      return;
    }

    context.read<HomeCubit>().load();
  }
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({required this.items});

  final List<ScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      child: Column(
        children: [
          for (final item in items)
            _TimelineRow(
              time: item.time,
              title: item.title,
              caption: item.caption,
              isCurrent: item.isCurrent,
            ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      child: Column(
        children: [
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.18),
                child: Icon(
                  _activityIcon(item.type),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text(item.title),
              subtitle: Text(item.caption),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.title,
    required this.caption,
    required this.isCurrent,
  });

  final String time;
  final String title;
  final String caption;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(time, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            isCurrent ? Icons.radio_button_checked : Icons.circle_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(caption, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _VerificationChip extends StatelessWidget {
  const _VerificationChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final verified = status == 'verified';
    final color = verified
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary;

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              verified ? Icons.verified_rounded : Icons.pending_actions_rounded,
              color: color,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(verified ? 'Terverifikasi' : 'Menunggu verifikasi'),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({
    required this.isAvailable,
    required this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAvailable
              ? Icons.check_circle_rounded
              : Icons.do_not_disturb_on_rounded,
          color: isAvailable ? colors.primary : colors.onSurfaceVariant,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          isAvailable ? 'Aktif' : 'Nonaktif',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isAvailable ? colors.primary : colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        Switch(
          value: isAvailable,
          onChanged: onChanged,
          activeThumbColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: IconButton(
        onPressed: () => context.go('/notifications'),
        icon: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.screen,
      children: const [
        CardSkeleton(height: 132),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 154),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 118),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 168),
      ],
    );
  }
}

OrderStatus _mapOrderStatus(String status) {
  return switch (status) {
    'confirmed' || 'scheduled' => OrderStatus.accepted,
    'on_the_way' => OrderStatus.onTheWay,
    'completed' => OrderStatus.completed,
    'cancelled' => OrderStatus.cancelled,
    _ => OrderStatus.requested,
  };
}

IconData _activityIcon(String type) {
  return switch (type) {
    'wallet' => Icons.account_balance_wallet_outlined,
    'profile' => Icons.verified_user_outlined,
    _ => Icons.history_rounded,
  };
}

String _formatCurrency(double value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp $buffer';
}
