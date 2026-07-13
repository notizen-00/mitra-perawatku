import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../domain/entities/notification.dart';
import '../cubit/notifications_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  NotificationCategory? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final notifications = state is NotificationsLoaded
              ? state.notifications
              : const <AppNotification>[];
          final unreadCount = notifications.where((item) => !item.isRead).length;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _AppBar(unreadCount: unreadCount),
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeaderDelegate(
                  selected: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.mobileMargin,
                  AppSpacing.sm,
                  AppSpacing.mobileMargin,
                  104,
                ),
                sliver: switch (state) {
                  NotificationsLoading() || NotificationsInitial() =>
                    const _Loading(),
                  NotificationsError(:final message) => SliverToBoxAdapter(
                    child: ErrorCard(
                      message: message,
                      onRetry: context.read<NotificationsCubit>().load,
                    ),
                  ),
                  NotificationsLoaded(:final notifications) =>
                    _ListContent(
                      notifications: notifications,
                      filter: _filter,
                    ),
                  _ => const SliverToBoxAdapter(
                    child: ErrorCard(
                      message: 'State notifikasi tidak dikenali.',
                    ),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();

    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/dashboard'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Row(
        children: [
          Text(
            'Notifikasi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.chip,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  '$unreadCount baru',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: cubit.markAllAsRead,
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Tandai dibaca'),
          ),
      ],
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.selected, required this.onChanged});

  final NotificationCategory? selected;
  final ValueChanged<NotificationCategory?> onChanged;

  static const List<(NotificationCategory?, String)> _options = [
    (null, 'Semua'),
    (NotificationCategory.booking, 'Booking'),
    (NotificationCategory.consultation, 'Konsultasi'),
    (NotificationCategory.payment, 'Pembayaran'),
    (NotificationCategory.verification, 'Verifikasi'),
    (NotificationCategory.system, 'Sistem'),
  ];

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.mobileMargin,
          vertical: 8,
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _options.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final (category, label) = _options[index];
            final isSelected = category == selected;

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(category),
              showCheckmark: false,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
              selectedColor: AppColors.primary,
              backgroundColor: colors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.chip,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : colors.outlineVariant,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          },
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

class _ListContent extends StatelessWidget {
  const _ListContent({required this.notifications, required this.filter});

  final List<AppNotification> notifications;
  final NotificationCategory? filter;

  @override
  Widget build(BuildContext context) {
    final filtered = filter == null
        ? notifications
        : notifications.where((item) => item.category == filter).toList();

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(child: _EmptyState(hasFilter: filter != null));
    }

    return SliverList.list(
      children: [
        for (final notification in filtered)
          _NotificationCard(
            notification: notification,
            onTap: () => _onTap(context, notification),
            onDelete: () => context.read<NotificationsCubit>().delete(
                  notification.id,
                ),
          ),
      ],
    );
  }

  void _onTap(BuildContext context, AppNotification notification) {
    context.read<NotificationsCubit>().markAsRead(notification);

    if (notification.referenceType == 'service_booking' &&
        notification.referenceId != null) {
      context.go('/orders/${notification.referenceId}');
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, icon, color) =
        _categoryStyle(context, notification.category);
    final isUnread = !notification.isRead;

    final card = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isUnread
            ? color.withValues(alpha: 0.06)
            : colors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isUnread ? color.withValues(alpha: 0.35) : colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.card,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isUnread ? 0.16 : 0.1),
                    borderRadius: AppRadius.control,
                  ),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(icon, color: color, size: 22),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              child: Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            notification.timeAgo,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
          border: Border.all(color: colors.error.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: Icon(Icons.delete_outline_rounded, color: colors.error),
      ),
      onDismissed: (_) => onDelete(),
      child: card,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            hasFilter ? 'Tidak ada notifikasi' : 'Belum ada notifikasi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              hasFilter
                  ? 'Tidak ditemukan notifikasi pada kategori ini.'
                  : 'Notifikasi pesanan, konsultasi, dan sistem akan muncul di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
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
    return SliverList.list(
      children: const [
        CardSkeleton(height: 96),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 96),
        SizedBox(height: AppSpacing.md),
        CardSkeleton(height: 96),
      ],
    );
  }
}

(String label, IconData icon, Color color) _categoryStyle(
  BuildContext context,
  NotificationCategory category,
) {
  final colors = Theme.of(context).colorScheme;

  return switch (category) {
    NotificationCategory.booking => (
      'Booking',
      Icons.assignment_outlined,
      colors.primary,
    ),
    NotificationCategory.consultation => (
      'Konsultasi',
      Icons.chat_bubble_outline_rounded,
      colors.secondary,
    ),
    NotificationCategory.payment => (
      'Pembayaran',
      Icons.payments_outlined,
      colors.tertiary,
    ),
    NotificationCategory.verification => (
      'Verifikasi',
      Icons.verified_user_rounded,
      colors.primary,
    ),
    NotificationCategory.system => (
      'Sistem',
      Icons.info_outline_rounded,
      colors.onSurfaceVariant,
    ),
  };
}
