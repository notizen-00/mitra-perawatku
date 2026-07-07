import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class StitchDashboardPage extends StatelessWidget {
  const StitchDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppFrame(
      activeIndex: 0,
      child: _DashboardContent(),
    );
  }
}

class StitchWalletPage extends StatelessWidget {
  const StitchWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppFrame(
      activeIndex: 2,
      child: _WalletContent(),
    );
  }
}

class StitchTrackingPage extends StatelessWidget {
  const StitchTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TrackingContent();
  }
}

class StitchMatchmakingPage extends StatelessWidget {
  const StitchMatchmakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MatchmakingContent();
  }
}

class StitchServiceSetupPage extends StatelessWidget {
  const StitchServiceSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServiceSetupContent();
  }
}

class StitchLoginPage extends StatefulWidget {
  const StitchLoginPage({super.key});

  @override
  State<StitchLoginPage> createState() => _StitchLoginPageState();
}

class _StitchLoginPageState extends State<StitchLoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final showHero = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      body: Row(
        children: [
          if (showHero)
            Expanded(
              child: Container(
                color: colors.surfaceContainerHigh,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BrandIcon(icon: Icons.medical_services_outlined),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Empowering Care Partnerships',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(color: colors.primary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Join a network of dedicated professionals providing elite homecare services with precision and compassion.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: const [
                            Expanded(
                              child: _FeatureMiniCard(
                                icon: Icons.verified_user_outlined,
                                label: 'Secure',
                                text: 'HIPAA Compliant Platform',
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _FeatureMiniCard(
                                icon: Icons.analytics_outlined,
                                label: 'Insight',
                                text: 'Real-time Patient Data',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: colors.surface,
              padding: AppSpacing.screen,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Please enter your credentials to access the partner portal.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _LabeledField(
                        label: 'EMAIL OR PHONE NUMBER',
                        hint: 'nurse@homecarepro.com',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _LabeledField(
                        label: 'PASSWORD',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        trailing: IconButton(
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () => context.go('/dashboard'),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(child: Divider(color: colors.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Text(
                              'OR LOGIN WITH',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          Expanded(child: Divider(color: colors.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.key_rounded),
                          label: const Text('Partner SSO Login'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Apply as a Partner'),
                        ),
                      ),
                    ],
                  ),
                    ),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {},
        backgroundColor: colors.surfaceContainerHighest,
        foregroundColor: colors.secondary,
        child: const Icon(Icons.help_outline_rounded),
      ),
    );
  }
}

class StitchRegisterPage extends StatelessWidget {
  const StitchRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final showHero = MediaQuery.sizeOf(context).width >= 860;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -120,
            child: _BlurCircle(color: colors.primary),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _BlurCircle(color: colors.secondary),
          ),
          Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Flex(
                  direction: showHero ? Axis.horizontal : Axis.vertical,
                  children: [
                    if (showHero)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  _BrandIcon(icon: Icons.medical_services_outlined),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Homecare Pro',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: colors.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Bergabunglah dengan Jaringan Tenaga Medis Profesional Kami.',
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Kelola jadwal konsultasi, rekam medis pasien, dan pendapatan Anda dalam satu platform terintegrasi.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: const [
                                  Expanded(
                                    child: _MetricCard(
                                      icon: Icons.groups_outlined,
                                      label: 'Komunitas',
                                      value: '5,000+',
                                      caption: 'Rekan Medis Terverifikasi',
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _MetricCard(
                                      icon: Icons.verified_user_outlined,
                                      label: 'Kepercayaan',
                                      value: '100%',
                                      caption: 'Aman & Terenkripsi',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (showHero) const SizedBox(width: AppSpacing.xl),
                    if (showHero)
                      const Expanded(child: _RegisterCard())
                    else
                      const _RegisterCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, compact ? 86 : 96, 16, 104),
      children: [
        const _RevenueCard(),
        SizedBox(height: compact ? 18 : 30),
        const _StitchUiAccessGrid(),
        SizedBox(height: compact ? 18 : 30),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: compact ? 10 : 20,
          crossAxisSpacing: compact ? 10 : 20,
          childAspectRatio: compact ? 0.76 : 0.86,
          children: const [
            _StatTile(
              icon: Icons.book_online_outlined,
              label: 'Active\nBooking',
              value: '3',
              color: AppColors.secondary,
            ),
            _StatTile(
              icon: Icons.calendar_month_outlined,
              label: "Today's\nSchedule",
              value: '4',
              color: AppColors.tertiary,
            ),
            _StatTile(
              icon: Icons.star_rounded,
              label: 'Rating',
              value: '4.9',
              color: Color(0xFFF59E0B),
            ),
          ],
        ),
        SizedBox(height: compact ? 24 : 34),
        _SectionTitle(
          title: 'Order Masuk',
          action: 'See All',
          onAction: () => context.go('/matchmaking'),
        ),
        const SizedBox(height: AppSpacing.md),
        _OrderCard(
          name: 'Bpk. Hery\nSusanto',
          service: 'General Checkup - Home Visit',
          time: '10:30 AM',
          tag: 'NEW REQUEST',
          distance: '3.2 km',
          onTap: () => context.go('/tracking'),
        ),
        const SizedBox(height: AppSpacing.md),
        _OrderCard(
          name: 'Ibu Siska Wijaya',
          service: 'Wound Care - Recurring',
          time: '02:15 PM',
          tag: 'PREMIUM',
          distance: '1.5 km',
          onTap: () => context.go('/tracking'),
        ),
        SizedBox(height: compact ? 24 : 34),
        Text(
          'Jadwal Hari Ini',
          style: TextStyle(fontSize: compact ? 22 : 25, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
        const _ScheduleTimeline(),
      ],
    );
  }
}

class _StitchUiAccessGrid extends StatelessWidget {
  const _StitchUiAccessGrid();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;
    const items = [
      _StitchAccessItem(
        icon: Icons.login_rounded,
        label: 'Login',
        route: '/login',
      ),
      _StitchAccessItem(
        icon: Icons.app_registration_rounded,
        label: 'Daftar',
        route: '/register',
      ),
      _StitchAccessItem(
        icon: Icons.radar_rounded,
        label: 'Match',
        route: '/matchmaking',
      ),
      _StitchAccessItem(
        icon: Icons.route_rounded,
        label: 'Tracking',
        route: '/tracking',
      ),
      _StitchAccessItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Wallet',
        route: '/wallet',
      ),
      _StitchAccessItem(
        icon: Icons.tune_rounded,
        label: 'Services',
        route: '/services',
      ),
    ];

    return _SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stitch UI',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: compact ? 3 : 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: compact ? 1.18 : 1.08,
            children: items,
          ),
        ],
      ),
    );
  }
}

class _StitchAccessItem extends StatelessWidget {
  const _StitchAccessItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppFrame extends StatelessWidget {
  const _AppFrame({required this.child, required this.activeIndex});

  final Widget child;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          child,
          const _TopBar(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomNav(activeIndex: activeIndex),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Container(
      height: compact ? 74 : 80,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: compact ? 42 : 50,
              height: compact ? 42 : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryContainer, width: 3),
              ),
              child: const CircleAvatar(
                backgroundColor: AppColors.surfaceContainer,
                child: Icon(Icons.medical_services_outlined, color: AppColors.primary),
              ),
            ),
            SizedBox(width: compact ? 8 : 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo,', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    'dr. Andi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (compact
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineMedium)
                        ?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 9 : 14,
                vertical: compact ? 7 : 8,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: AppRadius.chip,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: compact ? 6 : 10),
                  Text(
                    compact ? 'Avail' : 'Available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 30,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.chip,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: compact ? 10 : 22),
            Icon(Icons.notifications_none_rounded, size: compact ? 26 : 31),
          ],
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Container(
      height: compact ? 150 : 170,
      padding: EdgeInsets.all(compact ? 22 : 30),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: compact ? -28 : -20,
            top: compact ? -32 : -36,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0x1FFFFFFF),
              size: compact ? 100 : 122,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY REVENUE',
                style: TextStyle(
                  color: AppColors.primaryFixedDim,
                  fontSize: compact ? 13 : 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rp 850.000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 27 : 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppColors.primaryFixed, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '+12.5% from yesterday',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/wallet'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Withdraw',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return _SoftCard(
      padding: EdgeInsets.all(compact ? 12 : 20),
      child: SizedBox(
        height: compact ? 96 : 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: compact ? 24 : 30),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 12 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: compact ? 3 : 6),
            Text(
              value,
              style: TextStyle(
                fontSize: compact ? 23 : 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.name,
    required this.service,
    required this.time,
    required this.tag,
    required this.distance,
    this.onTap,
  });

  final String name;
  final String service;
  final String time;
  final String tag;
  final String distance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return _SoftCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 14 : 20),
      child: Row(
        children: [
          Container(
            width: compact ? 50 : 60,
            height: compact ? 50 : 60,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
          ),
          SizedBox(width: compact ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 17 : 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: compact ? 14 : 17,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                Row(
                  children: [
                    _TinyTag(text: tag, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    _TinyTag(text: distance, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 10 : 16),
          Container(
            width: compact ? 48 : 57,
            height: compact ? 48 : 57,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: compact ? 28 : 34),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTimeline extends StatelessWidget {
  const _ScheduleTimeline();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 190, color: AppColors.outlineVariant),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            children: const [
              _TimelineCard(
                time: '09:00 - 10:00',
                patient: 'Susi Astuti',
                address: 'Jl. Merpati No. 12, Jakarta',
                status: 'ONGOING',
                active: true,
              ),
              SizedBox(height: AppSpacing.lg),
              _TimelineCard(
                time: '13:00 - 14:00',
                patient: 'Rian Pratama',
                address: 'Apartemen Sudirman, Unit 4B',
                status: 'UPCOMING',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.time,
    required this.patient,
    required this.address,
    required this.status,
    this.active = false,
  });

  final String time;
  final String patient;
  final String address;
  final String status;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  time,
                  style: TextStyle(
                    color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _TinyTag(
                text: status,
                color: active ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            patient,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 17),
              const SizedBox(width: 4),
              Expanded(child: Text(address)),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Start Consultation'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Container(
      height: compact ? 68 : 72,
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: activeIndex == 0,
                route: '/dashboard',
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule',
                active: activeIndex == 1,
                route: '/tracking',
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                active: activeIndex == 2,
                route: '/wallet',
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                active: activeIndex == 3,
                route: '/services',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.route,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String route;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant;
    final compact = MediaQuery.sizeOf(context).width <= 390;
    return InkWell(
      borderRadius: AppRadius.chip,
      onTap: () => context.go(route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: AppRadius.chip,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: compact ? 22 : 24),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletContent extends StatelessWidget {
  const _WalletContent();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, compact ? 86 : 96, 16, 104),
      children: [
        const _WalletBalanceCard(),
        const SizedBox(height: AppSpacing.lg),
        const _WalletActions(),
        const SizedBox(height: AppSpacing.lg),
        const _SectionTitle(title: 'Recent Transactions', action: 'View All'),
        const SizedBox(height: AppSpacing.md),
        const _TransactionItem(
          icon: Icons.medical_services_outlined,
          title: 'Home Visit - Patient #1024',
          date: '24 Oct, 14:30',
          amount: '+Rp 150.000',
          status: 'Completed',
          positive: true,
        ),
        const _TransactionItem(
          icon: Icons.account_balance_outlined,
          title: 'Bank Withdrawal',
          date: '23 Oct, 09:15',
          amount: '-Rp 1.000.000',
          status: 'In Progress',
          positive: false,
        ),
        const _TransactionItem(
          icon: Icons.medical_services_outlined,
          title: 'Consultation Fee',
          date: '22 Oct, 18:20',
          amount: '+Rp 200.000',
          status: 'Completed',
          positive: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _WeeklyEarningsCard(),
      ],
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Saldo: Rp 3.250.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 24 : 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Withdraw'),
                ),
              ),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Top Up'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletActions extends StatelessWidget {
  const _WalletActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _RoundAction(icon: Icons.history_rounded, label: 'Riwayat'),
        _RoundAction(icon: Icons.pending_actions_outlined, label: 'Pending'),
        _RoundAction(icon: Icons.account_tree_outlined, label: 'Komisi'),
        _RoundAction(icon: Icons.redeem_outlined, label: 'Bonus'),
      ],
    );
  }
}

class _MatchmakingContent extends StatelessWidget {
  const _MatchmakingContent();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width <= 390;
    return Scaffold(
      backgroundColor: AppColors.error.withValues(alpha: 0.06),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
              SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
              Center(
                child: Container(
                  width: compact ? 56 : 64,
                  height: compact ? 56 : 64,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: Colors.white,
                    size: compact ? 32 : 38,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Pasien Membutuhkan Perawat',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Respon cepat membantu keselamatan pasien. Segera tinjau permintaan ini.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              _SoftCard(
                padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
                child: Column(
                  children: [
                    _MiniMap(height: compact ? 120 : 160, emergency: true),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: compact ? AppSpacing.sm : AppSpacing.md,
                      crossAxisSpacing: compact ? AppSpacing.sm : AppSpacing.md,
                      childAspectRatio: compact ? 1.7 : 1.45,
                      children: const [
                        _InfoTile(icon: Icons.route_outlined, label: 'Jarak', value: '2.1 KM'),
                        _InfoTile(icon: Icons.schedule_rounded, label: 'Estimasi', value: '7 Menit'),
                        _InfoTile(icon: Icons.medical_services_outlined, label: 'Layanan', value: 'Infus'),
                        _InfoTile(icon: Icons.payments_outlined, label: 'Biaya', value: 'Rp 150k'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              const Center(child: _CountdownCircle()),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(color: colors.error, width: 2),
                        padding: EdgeInsets.symmetric(vertical: compact ? 14 : 18),
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.go('/tracking'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        padding: EdgeInsets.symmetric(vertical: compact ? 14 : 18),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Terima'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ),
      ),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  const _TrackingContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: const [
              SizedBox(height: 64),
              _TrackingMap(),
              _TrackingPanel(),
              SizedBox(height: 90),
            ],
          ),
          const _TrackingTopBar(),
          const Align(
            alignment: Alignment.bottomCenter,
            child: _BottomNav(activeIndex: 1),
          ),
        ],
      ),
    );
  }
}

class _ServiceSetupContent extends StatelessWidget {
  const _ServiceSetupContent();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, compact ? 80 : 92, 16, 112),
            children: [
              const _ServiceProgress(),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              Text(
                'Select your services',
                style: TextStyle(fontSize: compact ? 23 : 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Choose the medical services you are qualified to provide. You can update these later in your profile.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              const _PricingCards(),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              const _ServiceGrid(),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              const _WarningCard(),
            ],
          ),
          const _SimpleHeader(title: 'Homecare Pro'),
          const Align(
            alignment: Alignment.bottomCenter,
            child: _ServiceFooter(),
          ),
        ],
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return _SoftCard(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Daftar Akun Baru',
            textAlign: TextAlign.center,
            style: compact
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Lengkapi data diri Anda sebagai mitra kesehatan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _RoleSelector(),
          const SizedBox(height: AppSpacing.md),
          const _IconTextField(icon: Icons.person_outline, hint: 'Nama Lengkap (Sesuai STR)'),
          const SizedBox(height: AppSpacing.sm),
          const _IconTextField(icon: Icons.mail_outline, hint: 'Email Aktif'),
          const SizedBox(height: AppSpacing.sm),
          const _IconTextField(icon: Icons.call_outlined, hint: 'Nomor Telepon / WhatsApp'),
          const SizedBox(height: AppSpacing.sm),
          const _IconTextField(icon: Icons.lock_outline, hint: 'Password', obscure: true),
          const SizedBox(height: AppSpacing.md),
          const _UploadBox(),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.go('/services'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Daftar'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sudah punya akun? Masuk di sini'),
          ),
        ],
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _FeatureMiniCard extends StatelessWidget {
  const _FeatureMiniCard({
    required this.icon,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: AppSpacing.sm),
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(caption, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.onPrimaryContainer, size: 42),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: trailing,
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 420,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.05),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _RoleChip(icon: Icons.medical_services_outlined, label: 'Dokter', active: true)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: _RoleChip(icon: Icons.medical_information_outlined, label: 'Perawat')),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.outlineVariant,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _IconTextField extends StatelessWidget {
  const _IconTextField({
    required this.icon,
    required this.hint,
    this.obscure = false,
  });

  final IconData icon;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: obscure ? const Icon(Icons.visibility_outlined) : null,
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 34),
          SizedBox(height: AppSpacing.xs),
          Text('Upload STR / SIP', style: TextStyle(fontWeight: FontWeight.w800)),
          Text('Format: PDF, JPG, PNG (Max 5MB)'),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.secondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.positive,
  });

  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final String status;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.primary : AppColors.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _SoftCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(date, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                _TinyTag(text: status, color: positive ? AppColors.primary : AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyEarningsCard extends StatelessWidget {
  const _WeeklyEarningsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Earnings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: AppSpacing.xs),
                Text('You earned 15% more than last week. Keep up the great work!'),
              ],
            ),
          ),
          SizedBox(
            width: 92,
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Bar(height: 36, color: AppColors.primary),
                _Bar(height: 54, color: AppColors.primary),
                _Bar(height: 46, color: AppColors.primary),
                _Bar(height: 76, color: AppColors.primary),
                _Bar(height: 88, color: AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.height, this.emergency = false});

  final double height;
  final bool emergency;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFFDCE9FF), Color(0xFFEFF4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MapPainter()),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: _TinyTag(
              text: emergency ? 'Rumah Pasien' : 'PASIEN',
              color: emergency ? AppColors.error : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(icon, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownCircle extends StatelessWidget {
  const _CountdownCircle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.82,
            strokeWidth: 7,
            color: Theme.of(context).colorScheme.error,
            backgroundColor: AppColors.surfaceContainerHighest,
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('15', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                Text('DETIK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingTopBar extends StatelessWidget {
  const _TrackingTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8)],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Text(
              'Live Tracking',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const _TinyTag(text: 'AKTIF', color: AppColors.primary),
            const Icon(Icons.more_vert_rounded),
          ],
        ),
      ),
    );
  }
}

class _TrackingMap extends StatelessWidget {
  const _TrackingMap();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return SizedBox(
      height: compact ? 320 : 397,
      child: Stack(
        children: [
          _MiniMap(height: compact ? 320 : 397),
          Positioned.fill(
            child: CustomPaint(painter: _RoutePainter()),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: const [
                _MapButton(icon: Icons.my_location_rounded),
                SizedBox(height: AppSpacing.sm),
                _MapButton(icon: Icons.layers_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)],
      ),
      child: Icon(icon),
    );
  }
}

class _TrackingPanel extends StatelessWidget {
  const _TrackingPanel();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -48),
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          children: const [
            _EtaCard(),
            SizedBox(height: AppSpacing.md),
            _PatientCard(),
            SizedBox(height: AppSpacing.md),
            _ActivityTimeline(),
          ],
        ),
      ),
    );
  }
}

class _EtaCard extends StatelessWidget {
  const _EtaCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Row(
        children: const [
          CircleAvatar(
            backgroundColor: Color(0x1A10B981),
            child: Icon(Icons.timer_outlined, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ESTIMASI KEDATANGAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                Text('12 Menit', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          SizedBox(height: 42, child: VerticalDivider()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('JARAK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              Text('4.2 KM', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bpk. Budi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    Text('Layanan: Infus'),
                  ],
                ),
              ),
              _TinyTag(text: 'DIPRIORITASKAN', color: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: const [
              Expanded(child: _ActionBox(icon: Icons.chat_outlined, label: 'Chat', color: AppColors.primary)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _ActionBox(icon: Icons.call_outlined, label: 'Call', color: AppColors.secondary)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _ActionBox(icon: Icons.directions_outlined, label: 'Navigate', color: AppColors.secondary, filled: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBox extends StatelessWidget {
  const _ActionBox({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: filled ? color : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: filled ? null : Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: filled ? Colors.white : color),
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : AppColors.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Timeline Aktivitas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: AppSpacing.md),
          _TimelineRow(title: 'Order Diterima', text: 'Pukul 08:30 WIB • Menunggu konfirmasi perawat', done: true),
          _TimelineRow(title: 'Berangkat', text: 'Pukul 09:15 WIB • Perawat dalam perjalanan', active: true),
          _TimelineRow(title: 'Tiba di Lokasi', text: 'Estimasi 09:42 WIB'),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.text,
    this.done = false,
    this.active = false,
  });

  final String title;
  final String text;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primary : active ? AppColors.secondary : AppColors.outlineVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color,
            child: done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active ? AppColors.secondary : AppColors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceProgress extends StatelessWidget {
  const _ServiceProgress();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Text('STEP 2 OF 3', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
            Spacer(),
            Text('Service Setup', style: TextStyle(color: AppColors.outline)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.chip,
          child: const LinearProgressIndicator(
            value: 0.66,
            minHeight: 8,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainer,
          ),
        ),
      ],
    );
  }
}

class _PricingCards extends StatelessWidget {
  const _PricingCards();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    if (compact) {
      return const Column(
        children: [
          _PricingCard(icon: Icons.payments_outlined, label: 'BASE CONSULTATION FEE'),
          SizedBox(height: AppSpacing.md),
          _PricingCard(icon: Icons.home_work_outlined, label: 'HOME VISIT SURCHARGE'),
        ],
      );
    }

    return const Row(
      children: [
        Expanded(
          child: _PricingCard(
            icon: Icons.payments_outlined,
            label: 'BASE CONSULTATION FEE',
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _PricingCard(
            icon: Icons.home_work_outlined,
            label: 'HOME VISIT SURCHARGE',
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(prefixText: 'Rp ', hintText: '0'),
          ),
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;
    const items = [
      ('Infusion', 'IV Drips, antibiotics, and vitamins.', Icons.vaccines_outlined, false),
      ('Wound Care', 'Post-op care, dressings, and chronic.', Icons.healing_outlined, false),
      ('Consult', 'General assessment and checkups.', Icons.medical_services_outlined, false),
      ('Cardiac', 'ECG monitoring and heart health.', Icons.monitor_heart_outlined, false),
      ('Lab Work', 'Blood collection and diagnostics.', Icons.biotech_outlined, true),
      ('Geriatric', 'Senior support and home mobility.', Icons.person_outline_rounded, false),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: compact ? 0.92 : 1.18,
      children: [
        for (final item in items)
          _ServiceCard(title: item.$1, text: item.$2, icon: item.$3, active: item.$4),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.text,
    required this.icon,
    required this.active,
  });

  final String title;
  final String text;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: active ? Colors.white : AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSpacing.xs),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (active)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.12)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.error),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'VERIFICATION REQUIRED\nSelected specialized services will require valid certification uploads.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceFooter extends StatelessWidget {
  const _ServiceFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () => context.go('/dashboard'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.medical_services_outlined, color: AppColors.onPrimaryContainer),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadThin = Paint()
      ..color = AppColors.surfaceDim.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.15 + i * 0.18);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 24), road);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 24), roadThin);
    }

    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.15 + i * 0.24);
      canvas.drawLine(Offset(x, -20), Offset(x + 28, size.height + 20), road);
      canvas.drawLine(Offset(x, -20), Offset(x + 28, size.height + 20), roadThin);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.68,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.32,
        size.width * 0.82,
        size.height * 0.2,
      );

    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);

    _drawMarker(canvas, Offset(size.width * 0.18, size.height * 0.8), AppColors.secondary);
    _drawMarker(canvas, Offset(size.width * 0.82, size.height * 0.2), AppColors.error);
  }

  void _drawMarker(Canvas canvas, Offset offset, Color color) {
    canvas.drawCircle(offset, 18, Paint()..color = color.withValues(alpha: 0.22));
    canvas.drawCircle(offset, 10, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
