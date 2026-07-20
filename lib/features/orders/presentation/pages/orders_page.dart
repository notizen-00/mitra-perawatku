import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../../shared/widgets/navigation/mitra_scaffold.dart';
import '../../domain/entities/incoming_order.dart';
import '../../domain/entities/order_booking.dart';
import '../widgets/incoming_order_dialog.dart';
import '../cubit/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..load(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  var _filter = _OrderFilter.active;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
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
            OrdersLoaded(:final orders) => _OrdersContent(
              orders: orders,
              filter: _filter,
              onFilterChanged: (value) => setState(() => _filter = value),
            ),
            _ => const ErrorCard(message: 'State orders tidak dikenali.'),
          },
        );
      },
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({
    required this.orders,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<OrderBooking> orders;
  final _OrderFilter filter;
  final ValueChanged<_OrderFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filteredOrders = orders.where(filter.includes).toList();

    return Column(
      children: [
        _OrderTabs(selected: filter, onChanged: onFilterChanged),
        const SizedBox(height: AppSpacing.md),
        if (filteredOrders.isEmpty)
          MedicalCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(_emptyText(filter)),
          )
        else
          for (final order in filteredOrders)
            _OrderListCard(order: order),
      ],
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.selected, required this.onChanged});

  final _OrderFilter selected;
  final ValueChanged<_OrderFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          for (final filter in _OrderFilter.values)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected == filter
                            ? colors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    filter.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected == filter
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderListCard extends StatelessWidget {
  const _OrderListCard({required this.order});

  final OrderBooking order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = _statusInfo(order.status, order.paymentStatus);

    return MedicalCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(12),
      onTap: () => _isNewRequest(order.status)
          ? _showIncomingOrder(context, order)
          : context.go('/orders/${order.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceIcon(serviceName: order.serviceName),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 11,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.patientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusPill(info: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _InlineMeta(
                      icon: Icons.calendar_today_outlined,
                      text: order.scheduledDate,
                    ),
                    _InlineMeta(
                      icon: Icons.schedule_outlined,
                      text: order.scheduledAt,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatCurrency(order.totalAmount),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _OrderActions(order: order),
        ],
      ),
    );
  }

  Future<void> _showIncomingOrder(
    BuildContext context,
    OrderBooking order,
  ) async {
    final cubit = context.read<OrdersCubit>();
    final accepted = await showIncomingOrderDialog(
      context: context,
      order: IncomingOrder(
        id: order.id,
        code: order.code,
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
      onAccept: () => cubit.accept(order.id),
      onDecline: () => cubit.decline(order.id),
    );

    if (!context.mounted) return;
    if (accepted == true) {
      context.go('/orders/${order.id}');
    }
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.serviceName});

  final String serviceName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lowerName = serviceName.toLowerCase();
    final icon = lowerName.contains('wound') || lowerName.contains('luka')
        ? Icons.healing_outlined
        : lowerName.contains('check') || lowerName.contains('health')
        ? Icons.monitor_heart_outlined
        : Icons.medical_services_outlined;
    final color = lowerName.contains('wound') || lowerName.contains('luka')
        ? colors.secondary
        : lowerName.contains('check') || lowerName.contains('health')
        ? colors.tertiary
        : colors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.control,
      ),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.info});

  final _StatusInfo info;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: info.background,
          borderRadius: AppRadius.chip,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (info.icon != null) ...[
                Icon(info.icon, size: 12, color: info.foreground),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: info.foreground,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.order});

  final OrderBooking order;

  @override
  Widget build(BuildContext context) {
    final category = _categoryOf(order.status);

    if (category == _OrderFilter.completed) {
      return Row(
        children: [
          Expanded(
            child: _CompactOutlinedButton(label: 'Beri Ulasan', onPressed: () {}),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CompactFilledButton(
              label: 'Lihat Detail',
              onPressed: () => context.go('/orders/${order.id}'),
            ),
          ),
        ],
      );
    }

    if (category == _OrderFilter.cancelled) {
      return _CompactOutlinedButton(
        label: 'Lihat Detail',
        onPressed: () => context.go('/orders/${order.id}'),
      );
    }

    if (_isNewRequest(order.status)) {
      return Row(
        children: [
          Expanded(
            child: _CompactFilledButton(
              label: 'Terima',
              onPressed: () => context.read<OrdersCubit>().accept(order.id),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CompactOutlinedButton(
              label: 'Tolak',
              color: Theme.of(context).colorScheme.error,
              onPressed: () => context.read<OrdersCubit>().decline(order.id),
            ),
          ),
        ],
      );
    }

    if (_isAcceptedStatus(order.status)) {
      final isPaid = _isPaid(order.paymentStatus);
      return Row(
        children: [
          Expanded(
            child: _CompactOutlinedButton(
              label: isPaid ? 'Lihat Detail' : 'Menunggu Pembayaran',
              onPressed: isPaid ? () => context.go('/orders/${order.id}') : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CompactFilledButton(
              label: isPaid ? 'Mulai Berangkat' : 'Belum Lunas',
              onPressed: isPaid
                  ? () => context.read<OrdersCubit>().startJourney(order.id)
                  : null,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _CompactOutlinedButton(label: 'Hubungi', onPressed: () {})),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _CompactFilledButton(
            label: order.status == 'on_the_way' ? 'Peta' : 'Lihat Detail',
            onPressed: () => order.status == 'on_the_way'
                ? context.go('/tracking')
                : context.go('/orders/${order.id}'),
          ),
        ),
      ],
    );
  }
}

class _CompactFilledButton extends StatelessWidget {
  const _CompactFilledButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}

class _CompactOutlinedButton extends StatelessWidget {
  const _CompactOutlinedButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
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
        CardSkeleton(height: 44),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 148),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 148),
      ],
    );
  }
}

enum _OrderFilter {
  active('Aktif'),
  completed('Selesai'),
  cancelled('Dibatalkan');

  const _OrderFilter(this.label);

  final String label;

  bool includes(OrderBooking order) => _categoryOf(order.status) == this;
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;
}

_OrderFilter _categoryOf(String status) {
  final normalized = status.toLowerCase();
  return switch (normalized) {
    'completed' || 'done' || 'finished' => _OrderFilter.completed,
    'cancelled' || 'canceled' || 'rejected' || 'declined' =>
      _OrderFilter.cancelled,
    _ => _OrderFilter.active,
  };
}

_StatusInfo _statusInfo(String status, String paymentStatus) {
  final normalized = status.toLowerCase();
  final isPaid = _isPaid(paymentStatus);
  return switch (normalized) {
    'confirmed' || 'scheduled' => isPaid
        ? const _StatusInfo(
            label: 'SIAP BERANGKAT',
            foreground: AppColors.primary,
            background: Color(0xFFCFF3E4),
          )
        : const _StatusInfo(
            label: 'MENUNGGU BAYAR',
            foreground: AppColors.secondary,
            background: Color(0xFFE0EAFF),
          ),
    'on_the_way' => const _StatusInfo(
      label: 'MENUJU LOKASI',
      foreground: AppColors.secondary,
      background: Color(0xFFDDE7FF),
      icon: Icons.near_me_rounded,
    ),
    'completed' || 'done' || 'finished' => const _StatusInfo(
      label: 'SELESAI',
      foreground: AppColors.primary,
      background: Color(0xFFDDF8EA),
    ),
    'cancelled' || 'canceled' || 'rejected' || 'declined' => const _StatusInfo(
      label: 'DIBATALKAN',
      foreground: AppColors.error,
      background: Color(0xFFFFE2DE),
    ),
    _ => const _StatusInfo(
      label: 'MENUNGGU',
      foreground: AppColors.secondary,
      background: Color(0xFFE0EAFF),
    ),
  };
}

bool _isNewRequest(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'pending' ||
      normalized == 'requested' ||
      normalized == 'waiting' ||
      normalized == 'new';
}

bool _isAcceptedStatus(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'confirmed' || normalized == 'scheduled';
}

bool _isPaid(String paymentStatus) {
  return paymentStatus.toLowerCase() == 'paid';
}

String _emptyText(_OrderFilter filter) {
  return switch (filter) {
    _OrderFilter.active => 'Belum ada order aktif',
    _OrderFilter.completed => 'Belum ada order selesai',
    _OrderFilter.cancelled => 'Belum ada order dibatalkan',
  };
}
