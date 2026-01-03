import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/booking_details_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/publish_ride_screen.dart';
import '../screens/ride_details_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/upcoming_rides_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/user_profile_screen.dart';
import 'go_router_refresh_stream.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final String loc = state.matchedLocation;

    final bool inWelcome = loc == '/welcome';
    final bool inVerification = loc == '/verification';

    if (!loggedIn && !(inWelcome || inVerification)) {
      return '/welcome';
    }
    if (loggedIn && (inWelcome || inVerification)) {
      return '/home';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/profile_setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/verification',
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchResultsScreen(
        from: (state.uri.queryParameters['from'] ?? '').toString(),
        to: (state.uri.queryParameters['to'] ?? '').toString(),
      ),
    ),
    GoRoute(
      path: '/ride/:rideId',
      builder: (context, state) => RideDetailsScreen(
        rideId: state.pathParameters['rideId']!,
      ),
    ),
    GoRoute(
      path: '/booking/:bookingId',
      builder: (context, state) => BookingDetailsScreen(
        bookingId: state.pathParameters['bookingId']!,
      ),
    ),
    GoRoute(
      path: '/payment/:rideId',
      builder: (context, state) => PaymentScreen(
        rideId: state.pathParameters['rideId']!,
      ),
    ),
    GoRoute(
      path: '/publish',
      builder: (context, state) => const PublishRideScreen(),
    ),
    GoRoute(
      path: '/upcoming-rides',
      builder: (context, state) => const UpcomingRidesScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const UserProfileScreen(),
    ),
  ],
);
