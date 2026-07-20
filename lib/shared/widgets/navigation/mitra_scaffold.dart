import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

class MitraScaffold extends StatelessWidget {
  const MitraScaffold({
    required this.title,
    required this.activeIndex,
    required this.child,
    super.key,
    this.onRefresh,
  });

  final String title;
  final int activeIndex;
  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final content = ListView(padding: AppSpacing.screen, children: [child]);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifikasi',
          ),
        ],
      ),
      body: onRefresh == null
          ? content
          : RefreshIndicator(onRefresh: onRefresh!, child: content),
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
