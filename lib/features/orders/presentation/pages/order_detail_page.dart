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
import '../../domain/entities/order_detail.dart';
import '../bloc/order_detail_bloc.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({required this.orderId, super.key});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderDetailBloc>()..add(OrderDetailRequested(orderId)),
      child: _OrderDetailView(orderId: orderId),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView({required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state is! OrderDetailLoaded || _isClosedStatus(state.order.status)) {
            return const SizedBox.shrink();
          }
          return _BottomAction(order: state.order);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<OrderDetailBloc>().add(OrderDetailRefreshed(orderId));
        },
        child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            return switch (state) {
              OrderDetailLoading() || OrderDetailInitial() => const _Loading(),
              OrderDetailError(:final message) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const _DetailAppBar(),
                  SliverPadding(
                    padding: AppSpacing.screen,
                    sliver: SliverToBoxAdapter(
                      child: _OrderLoadError(message: message),
                    ),
                  ),
                ],
              ),
              OrderDetailLoaded(:final order) => _DetailContent(order: order),
              _ => const _UnknownState(),
            };
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const _DetailAppBar(),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StatusHeaderDelegate(order: order),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.mobileMargin,
            AppSpacing.md,
            AppSpacing.mobileMargin,
            104,
          ),
          sliver: SliverList.list(
            children: [
              _PatientCard(order: order),
              const SizedBox(height: AppSpacing.sm),
              _AddressCard(order: order),
              const SizedBox(height: AppSpacing.sm),
              _ServiceSummaryCard(order: order),
              const SizedBox(height: AppSpacing.sm),
              _HistoryCard(order: order),
              const SizedBox(height: AppSpacing.sm),
              _NotesCard(order: order),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        onPressed: () => context.canPop() ? context.pop() : context.go('/orders'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        'Detail Pesanan',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.help_outline_rounded, size: 20),
        ),
      ],
    );
  }
}

class _StatusHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StatusHeaderDelegate({required this.order});

  final OrderDetail order;

  @override
  double get minExtent => 92;

  @override
  double get maxExtent => 112;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final colors = Theme.of(context).colorScheme;
    final status = _statusCopy(order.status, order.paymentStatus);
    final timeText = order.startedAt == '-'
        ? 'Jadwal ${order.scheduledAt}'
        : 'Dimulai pada ${order.startedAt}';
    final etaText = order.etaMinutes <= 0
        ? timeText
        : '$timeText (${order.etaMinutes} menit)';

    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.mobileMargin,
          6 - (2 * progress),
          AppSpacing.mobileMargin,
          6,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlue.withValues(
                  alpha: 0.04 + progress * 0.05,
                ),
                blurRadius: 20,
                offset: Offset(0, 8 - progress * 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Status Saat Ini',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ),
                    _TinyStatusPill(text: status.badge),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  status.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, size: 14, color: colors.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        etaText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StatusHeaderDelegate oldDelegate) {
    return oldDelegate.order != order;
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFDDF8EA),
            child: Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pasien', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(
                  order.patientName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _SmallChip(icon: Icons.badge_outlined, text: order.code),
                    if (order.patientPhone != '-')
                      _SmallChip(icon: Icons.phone_outlined, text: order.patientPhone),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _CircleAction(icon: Icons.chat_bubble_rounded, onPressed: () {}),
          const SizedBox(width: AppSpacing.xs),
          _CircleAction(icon: Icons.call_rounded, onPressed: () {}),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final distanceText = order.distanceKm <= 0
        ? 'Jarak belum tersedia'
        : '${order.distanceKm.toStringAsFixed(1)} km dari lokasi Anda';

    return MedicalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.addressLabel, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(order.addressText, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                _SmallChip(icon: Icons.route_outlined, text: distanceText),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/tracking'),
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
    );
  }
}

class _ServiceSummaryCard extends StatelessWidget {
  const _ServiceSummaryCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  label: 'Layanan Kesehatan',
                  value: order.serviceName,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _SummaryValue(
                label: 'Total Biaya',
                value: formatCurrency(order.totalAmount),
                color: AppColors.primary,
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: _PaymentChip(status: order.paymentStatus),
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFEFFDF6),
              borderRadius: AppRadius.control,
              border: Border.all(color: const Color(0xFFC4F0DA)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Keluhan:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.notes.trim().isEmpty
                        ? 'Tidak ada catatan keluhan dari pasien.'
                        : order.notes,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pesanan',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (order.histories.isEmpty)
            Text('Belum ada riwayat dari server.', style: Theme.of(context).textTheme.bodySmall)
          else
            for (var index = 0; index < order.histories.length; index++)
              _ChecklistRow(
                text: _historyTitle(order.histories[index]),
                done: index < order.histories.length - 1,
                active: index == order.histories.length - 1,
                caption: order.histories[index].notes,
              ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Data',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _InfoTile(label: 'Status', value: order.status)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _InfoTile(label: 'Jadwal', value: order.scheduledAt)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _InfoTile(label: 'Payment', value: order.paymentStatus)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: AppRadius.control,
            ),
            child: SizedBox(
              height: 72,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  _latestHistoryNote(order),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final action = _actionFor(order);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.mobileMargin,
          AppSpacing.sm,
          AppSpacing.mobileMargin,
          AppSpacing.sm,
        ),
        child: switch (action) {
          _OrderAction.request => Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .read<OrderDetailBloc>()
                          .add(OrderDetailRejected(order.id)),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Tolak'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => context
                          .read<OrderDetailBloc>()
                          .add(OrderDetailAccepted(order.id)),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Terima'),
                    ),
                  ),
                ),
              ],
            ),
          _OrderAction.waitingPayment => SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.hourglass_top_rounded),
                label: const Text('Menunggu Pembayaran'),
              ),
            ),
          _OrderAction.startJourney => SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => context
                    .read<OrderDetailBloc>()
                    .add(OrderDetailJourneyStarted(order.id)),
                icon: const Icon(Icons.near_me_rounded),
                label: const Text('Mulai Berangkat'),
              ),
            ),
          _OrderAction.onTheWay => Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/tracking'),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Buka Peta'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => context
                          .read<OrderDetailBloc>()
                          .add(OrderDetailArrived(order.id)),
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('Saya Sudah Sampai'),
                    ),
                  ),
                ),
              ],
            ),
          _OrderAction.handling => SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => context
                    .read<OrderDetailBloc>()
                    .add(OrderDetailTreatmentStarted(order.id)),
                icon: const Icon(Icons.medical_information_outlined),
                label: const Text('Tangani Pasien'),
              ),
            ),
          _OrderAction.finish => SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => context
                    .read<OrderDetailBloc>()
                    .add(OrderDetailCompleted(order.id)),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Selesaikan Layanan'),
              ),
            ),
          _OrderAction.none => SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.info_outline_rounded),
                label: Text(_statusActionLabel(order.status)),
              ),
            ),
        },
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.text,
    this.done = false,
    this.active = false,
    this.caption = '',
  });

  final String text;
  final bool done;
  final bool active;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = done || active ? AppColors.primary : colors.outlineVariant;
    final background = done || active ? AppColors.primary : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: SizedBox(
              width: 18,
              height: 18,
              child: done
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : active
                      ? const Center(
                          child: SizedBox(
                            width: 6,
                            height: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                      : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: active ? AppColors.primary : colors.onSurface,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
                if (caption.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const _DetailAppBar(),
        SliverPadding(
          padding: AppSpacing.screen,
          sliver: SliverList.list(
            children: const [
              CardSkeleton(height: 80),
              SizedBox(height: AppSpacing.sm),
              CardSkeleton(height: 92),
              SizedBox(height: AppSpacing.sm),
              CardSkeleton(height: 150),
              SizedBox(height: AppSpacing.sm),
              CardSkeleton(height: 170),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderLoadError extends StatelessWidget {
  const _OrderLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MedicalCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Pesanan tidak dapat dibuka',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: () => context.go('/orders'),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Lihat daftar pesanan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnknownState extends StatelessWidget {
  const _UnknownState();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _DetailAppBar(),
        SliverPadding(
          padding: AppSpacing.screen,
          sliver: SliverToBoxAdapter(
            child: ErrorCard(message: 'State detail pesanan tidak dikenali.'),
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyStatusPill extends StatelessWidget {
  const _TinyStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFDDF8EA),
        borderRadius: AppRadius.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontSize: 9,
              ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final paid = status.toLowerCase() == 'paid';
    final color = paid ? AppColors.primary : Theme.of(context).colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          paid ? 'Pembayaran lunas' : 'Pembayaran $status',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontSize: 10,
              ),
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.control,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCopy {
  const _StatusCopy({required this.title, required this.badge});

  final String title;
  final String badge;
}

_StatusCopy _statusCopy(String status, String paymentStatus) {
  final isPaid = paymentStatus.toLowerCase() == 'paid';
  return switch (status.toLowerCase()) {
    'on_the_way' => const _StatusCopy(
        title: 'Dalam Perjalanan',
        badge: 'Aktif',
      ),
    'confirmed' || 'scheduled' => _StatusCopy(
        title: isPaid ? 'Siap Berangkat' : 'Menunggu Pembayaran',
        badge: 'Aktif',
      ),
    'completed' => const _StatusCopy(title: 'Pesanan Selesai', badge: 'Selesai'),
    'cancelled' => const _StatusCopy(title: 'Pesanan Dibatalkan', badge: 'Batal'),
    _ => const _StatusCopy(title: 'Menunggu Konfirmasi', badge: 'Aktif'),
  };
}

String _historyTitle(OrderHistory history) {
  if (history.title.trim().isNotEmpty) {
    final time = history.createdAt == '-' ? '' : ' - ${history.createdAt}';
    return '${history.title}$time';
  }

  final status = history.status.replaceAll('_', ' ');
  final title = status.isEmpty || status == '-' ? 'Riwayat pesanan' : status;
  final time = history.createdAt == '-' ? '' : ' - ${history.createdAt}';
  return '${_titleCase(title)}$time';
}

String _latestHistoryNote(OrderDetail order) {
  final notes = order.histories
      .map((history) => history.notes.trim())
      .where((note) => note.isNotEmpty)
      .toList();

  if (notes.isNotEmpty) return notes.last;
  if (order.notes.trim().isNotEmpty) return order.notes;
  return 'Belum ada catatan tambahan dari server.';
}

String _titleCase(String value) {
  return value
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

bool _isNewRequest(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'pending' ||
      normalized == 'requested' ||
      normalized == 'waiting' ||
      normalized == 'new';
}

bool _isClosedStatus(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'completed' ||
      normalized == 'cancelled' ||
      normalized == 'canceled' ||
      normalized == 'rejected' ||
      normalized == 'declined';
}

enum _OrderAction {
  request,
  waitingPayment,
  startJourney,
  onTheWay,
  handling,
  finish,
  none,
}

_OrderAction _actionFor(OrderDetail order) {
  final status = order.status.toLowerCase();
  final isPaid = order.paymentStatus.toLowerCase() == 'paid';

  if (_isNewRequest(status)) return _OrderAction.request;
  if (status == 'confirmed' || status == 'scheduled') {
    return isPaid ? _OrderAction.startJourney : _OrderAction.waitingPayment;
  }
  if (status == 'on_the_way') {
    if (!_hasHistory(order, 'arrival')) return _OrderAction.onTheWay;
    if (!_hasHistory(order, 'treatment_started')) return _OrderAction.handling;
    return _OrderAction.finish;
  }
  return _OrderAction.none;
}

bool _hasHistory(OrderDetail order, String marker) {
  final normalizedMarker = marker.toLowerCase();
  return order.histories.any((history) {
    final treatmentType = history.treatmentType.toLowerCase();
    final title = history.title.toLowerCase();
    final notes = history.notes.toLowerCase();
    return treatmentType == normalizedMarker ||
        title.contains(normalizedMarker.replaceAll('_', ' ')) ||
        notes.contains(normalizedMarker.replaceAll('_', ' ')) ||
        (normalizedMarker == 'arrival' &&
            (title.contains('sampai') || title.contains('tiba'))) ||
        (normalizedMarker == 'treatment_started' &&
            title.contains('penanganan'));
  });
}

String _statusActionLabel(String status) {
  return switch (status.toLowerCase()) {
    'completed' => 'Pesanan Selesai',
    'cancelled' || 'canceled' => 'Pesanan Dibatalkan',
    'rejected' || 'declined' => 'Pesanan Ditolak',
    _ => 'Belum Ada Aksi',
  };
}
