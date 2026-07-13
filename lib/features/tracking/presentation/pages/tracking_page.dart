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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.near_me_rounded, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                tracking.hasActiveService
                    ? 'Live map aktif untuk perjalanan ini'
                    : 'Belum ada perjalanan aktif',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
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
