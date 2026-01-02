import 'package:flutter/material.dart';

// AUTH
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/role_selection_screen.dart';

// DASHBOARD
import '../screens/dashboard/dashboard_screen.dart';

// RIDES
import '../screens/rides/search_rides_screen.dart';
import '../screens/rides/create_ride_screen.dart';
import '../screens/rides/ride_details_screen.dart';

// REQUESTS
import '../screens/ride_requests_screen.dart';

// PROFILE
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/driver/my_rides_screen.dart';
import '../screens/driver/my_proposals_screen.dart';
import '../screens/driver/simple_proposals_screen.dart';
// import '../screens/vehicle/my_vehicle_screen.dart'; // Commenté pour l'instant
import '../screens/wallet/wallet_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_chat_screen.dart';
import '../screens/security/security_screen.dart';
import '../screens/settings/settings_screen.dart';

// VEHICLE
import '../screens/vehicle/my_vehicles_screen.dart';
import '../screens/vehicle/add_vehicle_screen.dart';

// WALLET
import '../screens/wallet/wallet_screen.dart';

// GROUPS
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_chat_screen.dart';

// SETTINGS / SECURITY
import '../screens/security/security_screen.dart';
import '../screens/settings/settings_screen.dart';

// MODELS (for arguments)
import '../models/ride.dart';
import '../models/group.dart';

class AppRoutes {
  // =====================
  // Route names
  // =====================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';

  static const String dashboard = '/dashboard';

  static const String searchRides = '/search-rides';
  static const String createRide = '/create-ride';
  static const String rideDetails = '/ride-details';

  static const String rideRequests = '/ride-requests';

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String myRides = '/my-rides';
  static const String myProposals = '/my-proposals';
  static const String simpleProposals = '/simple-proposals';
  static const String myVehicle = '/my-vehicle';
  static const String wallet = '/wallet';
  static const String groups = '/groups';
  static const String groupChat = '/group-chat';
  static const String security = '/security';
  static const String settings = '/settings';

  // =====================
  // Static routes (no arguments)
  // =====================
  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    roleSelection: (_) => const RoleSelectionScreen(),

    dashboard: (_) => const DashboardScreen(),

    searchRides: (_) => const SearchRidesScreen(),
    createRide: (_) => const CreateRideScreen(),

    rideRequests: (_) => const RideRequestsScreen(),

    profile: (_) => const ProfileScreen(),
    editProfile: (_) => const EditProfileScreen(),
    myRides: (_) => const MyRidesScreen(),
    myProposals: (_) => const MyProposalsScreen(),
    simpleProposals: (_) => const SimpleProposalsScreen(),
    // myVehicle: (_) => const MyVehicleScreen(), // Commenté pour l'instant
    wallet: (_) => const WalletScreen(),
    groups: (_) => const GroupsScreen(),
    security: (_) => const SecurityScreen(),
    settings: (_) => const SettingsScreen(),
  };

  // =====================
  // Dynamic routes (with arguments)
  // =====================
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case rideDetails:
        final ride = settings.arguments as Ride;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RideDetailsScreen(ride: ride),
        );

      case groupChat:
        final group = settings.arguments as Group;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => GroupChatScreen(group: group),
        );

      default:
        return null;
    }
  }
}
