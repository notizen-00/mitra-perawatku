import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/stitch_ui/presentation/pages/stitch_pages.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const StitchLoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const StitchRegisterPage()),
    GoRoute(path: '/matchmaking', builder: (context, state) => const StitchMatchmakingPage()),
    GoRoute(path: '/tracking', builder: (context, state) => const StitchTrackingPage()),
    GoRoute(path: '/wallet', builder: (context, state) => const StitchWalletPage()),
    GoRoute(path: '/services', builder: (context, state) => const StitchServiceSetupPage()),
  ],
);
