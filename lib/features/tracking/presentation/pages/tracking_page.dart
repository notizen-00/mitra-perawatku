import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../domain/entities/active_tracking.dart';
import '../cubit/tracking_cubit.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TrackingCubit>()..load(),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: context.read<TrackingCubit>().load,
        child: BlocBuilder<TrackingCubit, TrackingState>(
          builder: (context, state) {
            return switch (state) {
              TrackingLoading() || TrackingInitial() => const _LoadingMap(),
              TrackingError(:final message) => CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const _TrackingAppBar(),
                    SliverPadding(
                      padding: AppSpacing.screen,
                      sliver: SliverToBoxAdapter(
                        child: ErrorCard(
                          message: message,
                          onRetry: context.read<TrackingCubit>().load,
                        ),
                      ),
                    ),
                  ],
                ),
              TrackingLoaded(:final tracking) => _TrackingMap(tracking: tracking),
              _ => const _UnknownState(),
            };
          },
        ),
      ),
    );
  }
}

class _TrackingMap extends StatelessWidget {
  const _TrackingMap({required this.tracking});

  final ActiveTracking tracking;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const _TrackingAppBar(),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _LiveMapPainter()),
              Positioned(
                left: AppSpacing.mobileMargin,
                right: AppSpacing.mobileMargin,
                top: AppSpacing.md,
                child: _StatusCard(tracking: tracking),
              ),
              Positioned(
                left: AppSpacing.mobileMargin,
                right: AppSpacing.mobileMargin,
                bottom: AppSpacing.lg,
                child: _NavigationCard(tracking: tracking),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrackingAppBar extends StatelessWidget {
  const _TrackingAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        onPressed: () => context.canPop() ? context.pop() : context.go('/orders'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        'Peta Tracking',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
      actions: [
        IconButton(
          onPressed: context.read<TrackingCubit>().load,
          icon: const Icon(Icons.my_location_rounded),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.tracking});

  final ActiveTracking tracking;

  @override
  Widget build(BuildContext context) {
    final distance = tracking.distanceKm <= 0
        ? 'Jarak belum tersedia'
        : '${tracking.distanceKm.toStringAsFixed(1)} km';
    final eta = tracking.etaMinutes <= 0
        ? 'ETA dihitung'
        : '${tracking.etaMinutes} menit';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFDDF8EA),
              child: Icon(Icons.route_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tracking.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${tracking.patientName} - $distance - $eta',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({required this.tracking});

  final ActiveTracking tracking;

  @override
  Widget build(BuildContext context) {
    final action = _trackingActionFor(tracking);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_trackingActionIcon(action), color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _trackingActionText(action),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (action != _TrackingAction.idle) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: () => _handleTrackingAction(context, action, tracking.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.control,
                    ),
                  ),
                  icon: Icon(_trackingActionButtonIcon(action)),
                  label: Text(_trackingActionButtonLabel(action)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTrackingAction(
    BuildContext context,
    _TrackingAction action,
    int bookingId,
  ) {
    final cubit = context.read<TrackingCubit>();
    switch (action) {
      case _TrackingAction.arrive:
        cubit.markArrived(bookingId);
        break;
      case _TrackingAction.handle:
        cubit.startTreatment(bookingId);
        break;
      case _TrackingAction.finish:
        cubit.complete(bookingId);
        break;
      case _TrackingAction.idle:
        break;
    }
  }
}

class _LoadingMap extends StatelessWidget {
  const _LoadingMap();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const _TrackingAppBar(),
        SliverPadding(
          padding: AppSpacing.screen,
          sliver: SliverList.list(
            children: const [
              CardSkeleton(height: 88),
              SizedBox(height: AppSpacing.md),
              CardSkeleton(height: 460),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnknownState extends StatelessWidget {
  const _UnknownState();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _TrackingAppBar(),
        SliverPadding(
          padding: AppSpacing.screen,
          sliver: SliverToBoxAdapter(
            child: ErrorCard(message: 'State tracking tidak dikenali.'),
          ),
        ),
      ],
    );
  }
}

class _LiveMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8F1F7));

    final road = Paint()
      ..color = const Color(0xFFBFD3DF)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final thinRoad = Paint()
      ..color = const Color(0xFFD5E1E9)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-20, size.height * 0.68),
      Offset(size.width + 20, size.height * 0.28),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.16, -20),
      Offset(size.width * 0.84, size.height + 20),
      thinRoad,
    );
    canvas.drawLine(
      Offset(-20, size.height * 0.36),
      Offset(size.width * 0.92, size.height * 0.88),
      thinRoad,
    );

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.48,
        size.width * 0.58,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.66,
        size.width * 0.84,
        size.height * 0.34,
      );
    canvas.drawPath(path, route);

    _pin(canvas, Offset(size.width * 0.18, size.height * 0.72), AppColors.primary);
    _pin(canvas, Offset(size.width * 0.84, size.height * 0.34), AppColors.error);
  }

  void _pin(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 18, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(center, 9, Paint()..color = color);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _TrackingAction {
  arrive,
  handle,
  finish,
  idle,
}

_TrackingAction _trackingActionFor(ActiveTracking tracking) {
  if (tracking.status.toLowerCase() != 'on_the_way') {
    return tracking.hasActiveService ? _TrackingAction.idle : _TrackingAction.idle;
  }

  if (!_hasHistory(tracking, 'arrival')) return _TrackingAction.arrive;
  if (!_hasHistory(tracking, 'treatment_started')) return _TrackingAction.handle;
  return _TrackingAction.finish;
}

bool _hasHistory(ActiveTracking tracking, String marker) {
  final normalizedMarker = marker.toLowerCase();
  final readableMarker = normalizedMarker.replaceAll('_', ' ');
  return tracking.histories.any((history) {
    final treatmentType = history.treatmentType.toLowerCase();
    final title = history.title.toLowerCase();
    final notes = history.notes.toLowerCase();
    return treatmentType == normalizedMarker ||
        title.contains(readableMarker) ||
        notes.contains(readableMarker) ||
        (normalizedMarker == 'arrival' &&
            (title.contains('sampai') || title.contains('tiba'))) ||
        (normalizedMarker == 'treatment_started' &&
            title.contains('penanganan'));
  });
}

String _trackingActionText(_TrackingAction action) {
  return switch (action) {
    _TrackingAction.arrive => 'Live map aktif. Tandai jika Anda sudah tiba.',
    _TrackingAction.handle => 'Anda sudah sampai. Mulai tangani pasien terlebih dahulu.',
    _TrackingAction.finish => 'Penanganan sedang berjalan. Selesaikan setelah layanan selesai.',
    _TrackingAction.idle => 'Belum ada perjalanan aktif',
  };
}

String _trackingActionButtonLabel(_TrackingAction action) {
  return switch (action) {
    _TrackingAction.arrive => 'Saya Sudah Sampai',
    _TrackingAction.handle => 'Tangani Pasien',
    _TrackingAction.finish => 'Selesaikan Layanan',
    _TrackingAction.idle => 'Tidak Ada Aksi',
  };
}

IconData _trackingActionIcon(_TrackingAction action) {
  return switch (action) {
    _TrackingAction.arrive => Icons.near_me_rounded,
    _TrackingAction.handle => Icons.medical_information_outlined,
    _TrackingAction.finish => Icons.task_alt_rounded,
    _TrackingAction.idle => Icons.info_outline_rounded,
  };
}

IconData _trackingActionButtonIcon(_TrackingAction action) {
  return switch (action) {
    _TrackingAction.arrive => Icons.location_on_outlined,
    _TrackingAction.handle => Icons.healing_outlined,
    _TrackingAction.finish => Icons.check_circle_outline_rounded,
    _TrackingAction.idle => Icons.info_outline_rounded,
  };
}
