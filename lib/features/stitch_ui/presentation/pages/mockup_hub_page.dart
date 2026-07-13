import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';

class MockupHubPage extends StatelessWidget {
  const MockupHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _MockupItem('Dashboard', '/mockup/dashboard', Icons.dashboard_outlined),
      _MockupItem('Login', '/mockup/login', Icons.login_rounded),
      _MockupItem(
        'Register',
        '/mockup/register',
        Icons.app_registration_rounded,
      ),
      _MockupItem('Matchmaking', '/mockup/matchmaking', Icons.radar_rounded),
      _MockupItem('Tracking', '/mockup/tracking', Icons.route_rounded),
      _MockupItem(
        'Wallet',
        '/mockup/wallet',
        Icons.account_balance_wallet_outlined,
      ),
      _MockupItem('Services', '/mockup/services', Icons.tune_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mockup Stitch UI'),
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Text(
            'Halaman ini khusus referensi statis. Flow aplikasi real tetap memakai route utama dan data API.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 720 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              for (final item in items)
                MedicalCard(
                  onTap: () => context.go(item.route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 32),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockupItem {
  const _MockupItem(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;
}
