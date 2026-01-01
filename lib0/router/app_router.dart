import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/booking_details_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/publish_ride_screen.dart';
import '../screens/ride_details_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/upcoming_rides_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/user_profile_screen.dart';

// Widgets & Helpers
import 'go_router_refresh_stream.dart';
import '../widgets/bottom_nav.dart';

// 1. LE WRAPPER : Il affiche la Navbar et change le contenu au milieu
class ScaffoldWithNavbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavbar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    // On définit quelle icône est allumée selon l'index du shell
    String currentRoute = 'home';
    switch (navigationShell.currentIndex) {
      case 0: currentRoute = 'home'; break;
      case 1: currentRoute = 'search'; break;
      case 2: currentRoute = 'rides'; break;
      case 3: currentRoute = 'profile'; break;
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNav(
        current: currentRoute,
        // C'est cette ligne qui répare le problème du clic !
        onTap: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final String loc = state.matchedLocation;

    if (!loggedIn && loc != '/welcome' && loc != '/verification') return '/welcome';
    if (loggedIn && (loc == '/welcome' || loc == '/verification')) return '/home';
    return null;
  },
  routes: <RouteBase>[
    // Routes SANS barre (Plein écran)
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/profile_setup', builder: (context, state) => const ProfileSetupScreen()),
    GoRoute(path: '/verification', builder: (context, state) => const VerificationScreen()),

    // --- ROUTES AVEC BARRE (NAVIGATION PRINCIPALE) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavbar(navigationShell: navigationShell);
      },
      branches: [
        // Index 0 : Accueil
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ]),
        // Index 1 : Recherche
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/search',
            builder: (context, state) => SearchResultsScreen(
              from: state.uri.queryParameters['from'] ?? '',
              to: state.uri.queryParameters['to'] ?? '',
            ),
          ),
        ]),
        // Index 2 : Mes Trajets
        StatefulShellBranch(routes: [
          GoRoute(path: '/upcoming-rides', builder: (context, state) => const UpcomingRidesScreen()),
        ]),
        // Index 3 : Profil
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (context, state) => const UserProfileScreen()),
        ]),
      ],
    ),

    // --- ROUTES DE DÉTAILS (S'ouvrent au-dessus de tout) ---
    GoRoute(
      path: '/ride/:rideId',
      builder: (context, state) => RideDetailsScreen(rideId: state.pathParameters['rideId']!),
    ),
    GoRoute(
      path: '/publish',
      builder: (context, state) => const PublishRideScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);