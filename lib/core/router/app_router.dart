import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../services/auth_session.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/services/presentation/pages/partner_services_page.dart';
import '../../features/stitch_ui/presentation/pages/mockup_hub_page.dart';
import '../../features/stitch_ui/presentation/pages/stitch_pages.dart';
import '../../features/tracking/presentation/pages/tracking_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    if (!sl.isRegistered<AuthSession>()) return null;

    final session = sl<AuthSession>();
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/';
    final isMockupRoute = state.matchedLocation.startsWith('/mockup');
    final isProtectedRoute =
        state.matchedLocation != '/login' &&
        state.matchedLocation != '/register' &&
        state.matchedLocation != '/' &&
        !isMockupRoute;

    if (session.isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }

    if (!session.isAuthenticated && isProtectedRoute) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const HomePage()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return OrderDetailPage(orderId: id);
      },
    ),
    GoRoute(
      path: '/tracking',
      builder: (context, state) => const TrackingPage(),
    ),
    GoRoute(path: '/wallet', builder: (context, state) => const WalletPage()),
    GoRoute(
      path: '/services',
      builder: (context, state) => const PartnerServicesPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/mockup',
      builder: (context, state) => const MockupHubPage(),
    ),
    GoRoute(
      path: '/mockup/dashboard',
      builder: (context, state) => const StitchDashboardPage(),
    ),
    GoRoute(
      path: '/mockup/login',
      builder: (context, state) => const StitchLoginPage(),
    ),
    GoRoute(
      path: '/mockup/register',
      builder: (context, state) => const StitchRegisterPage(),
    ),
    GoRoute(
      path: '/mockup/matchmaking',
      builder: (context, state) => const StitchMatchmakingPage(),
    ),
    GoRoute(
      path: '/mockup/tracking',
      builder: (context, state) => const StitchTrackingPage(),
    ),
    GoRoute(
      path: '/mockup/wallet',
      builder: (context, state) => const StitchWalletPage(),
    ),
    GoRoute(
      path: '/mockup/services',
      builder: (context, state) => const StitchServiceSetupPage(),
    ),
  ],
);
