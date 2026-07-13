import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../../../../shared/widgets/common/error_card.dart';
import '../../../../shared/widgets/loaders/card_skeleton.dart';
import '../../../home/domain/entities/home_summary.dart';
import '../../../home/presentation/cubit/home_cubit.dart';

class RealOrdersPage extends StatelessWidget {
  const RealOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _RealScaffold(
      title: 'Orders',
      activeIndex: 1,
      child: _ApiListView(
        loader: () {
          return sl<ApiClient>().get(
            ApiEndpoints.serviceBookings,
            queryParameters: {
              'assigned_partner_user_id': sl<AuthSession>().userId,
              'per_page': 50,
            },
          );
        },
        emptyTitle: 'Belum ada order',
        itemBuilder: (context, item) {
          return MedicalCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['booking_code']?.toString() ?? 'Booking',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_serviceName(item)),
                const SizedBox(height: AppSpacing.sm),
                Text('${_patientName(item)} - ${item['status'] ?? 'pending'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RealWalletPage extends StatelessWidget {
  const RealWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return _RealScaffold(
            title: 'Wallet',
            activeIndex: 2,
            child: switch (state) {
              HomeLoading() || HomeInitial() => const _LoadingList(),
              HomeError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<HomeCubit>().load,
              ),
              HomeLoaded(:final summary) => _WalletContent(summary: summary),
              _ => const ErrorCard(message: 'State wallet tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}

class RealServicesPage extends StatelessWidget {
  const RealServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _RealScaffold(
      title: 'Layanan',
      activeIndex: 3,
      child: _ApiListView(
        loader: () {
          return sl<ApiClient>().get(
            ApiEndpoints.serviceApplications,
            queryParameters: {'per_page': 50},
          );
        },
        emptyTitle: 'Belum ada layanan diajukan',
        itemBuilder: (context, item) {
          final service = _object(item['service']);
          return MedicalCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service?['name']?.toString() ?? 'Layanan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Radius: ${item['coverage_radius_km'] ?? '-'} km'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Status: ${item['is_active'] == true ? 'Aktif' : 'Nonaktif'}'
                  ' / ${item['is_verified'] == true ? 'Terverifikasi' : 'Menunggu'}',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RealTrackingPage extends StatelessWidget {
  const RealTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return _RealScaffold(
            title: 'Tracking',
            activeIndex: 1,
            child: switch (state) {
              HomeLoading() || HomeInitial() => const _LoadingList(),
              HomeError(:final message) => ErrorCard(
                message: message,
                onRetry: context.read<HomeCubit>().load,
              ),
              HomeLoaded(:final summary) => _TrackingContent(
                service: summary.activeService,
              ),
              _ => const ErrorCard(message: 'State tracking tidak dikenali.'),
            },
          );
        },
      ),
    );
  }
}

class RealProfilePage extends StatelessWidget {
  const RealProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _RealScaffold(
      title: 'Profil',
      activeIndex: 4,
      child: FutureBuilder<Map<String, dynamic>>(
        future: sl<ApiClient>().get(ApiEndpoints.me),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingList();
          }

          if (snapshot.hasError) {
            return ErrorCard(message: snapshot.error.toString());
          }

          final data = _object(snapshot.data?['data']) ?? snapshot.data ?? {};
          final profile = _object(data['partner_profile']);

          return MedicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name']?.toString() ?? 'Mitra',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(data['email']?.toString() ?? '-'),
                const SizedBox(height: AppSpacing.lg),
                Text('Profesi: ${profile?['profession'] ?? '-'}'),
                Text('Verifikasi: ${profile?['verification_status'] ?? '-'}'),
                Text('Lokasi: ${profile?['work_location'] ?? '-'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RealScaffold extends StatelessWidget {
  const _RealScaffold({
    required this.title,
    required this.activeIndex,
    required this.child,
  });

  final String title;
  final int activeIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/mockup'),
            icon: const Icon(Icons.layers_outlined),
            label: const Text('Mockup'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(padding: AppSpacing.screen, children: [child]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
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

class _ApiListView extends StatelessWidget {
  const _ApiListView({
    required this.loader,
    required this.itemBuilder,
    required this.emptyTitle,
  });

  final Future<Map<String, dynamic>> Function() loader;
  final Widget Function(BuildContext context, Map<String, dynamic> item)
  itemBuilder;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingList();
        }

        if (snapshot.hasError) {
          return ErrorCard(message: snapshot.error.toString());
        }

        final items = _list(snapshot.data);
        if (items.isEmpty) {
          return MedicalCard(child: Text(emptyTitle));
        }

        return Column(
          children: [for (final item in items) itemBuilder(context, item)],
        );
      },
    );
  }
}

class _WalletContent extends StatelessWidget {
  const _WalletContent({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricCard(
          label: 'Saldo Mitra',
          value: _formatCurrency(summary.walletBalance),
        ),
        const SizedBox(height: AppSpacing.md),
        _MetricCard(
          label: 'Pendapatan Hari Ini',
          value: _formatCurrency(summary.todayIncome),
        ),
        const SizedBox(height: AppSpacing.md),
        _MetricCard(
          label: 'Pending',
          value: _formatCurrency(summary.pendingIncome),
        ),
      ],
    );
  }
}

class _TrackingContent extends StatelessWidget {
  const _TrackingContent({required this.service});

  final ActiveService service;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(service.patientName),
          const SizedBox(height: AppSpacing.lg),
          Text('Status: ${service.status}'),
          Text('ETA: ${service.etaMinutes} menit'),
          Text('Jarak: ${service.distanceKm} km'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

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

List<Map<String, dynamic>> _list(Map<String, dynamic>? response) {
  final data = response?['data'];
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  if (data is Map<String, dynamic> && data['data'] is List) {
    return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

Map<String, dynamic>? _object(Object? value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}

String _serviceName(Map<String, dynamic> booking) {
  return _object(booking['service'])?['name']?.toString() ?? 'Layanan';
}

String _patientName(Map<String, dynamic> booking) {
  return _object(booking['patient'])?['name']?.toString() ?? 'Pasien';
}

String _formatCurrency(double value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}
