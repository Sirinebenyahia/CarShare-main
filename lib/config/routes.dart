import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/rides/search_rides_screen.dart';
import '../screens/rides/create_ride_screen.dart';
import '../screens/rides/ride_details_screen.dart';
import '../screens/ride_requests_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/vehicle/my_vehicles_screen.dart';
import '../screens/vehicle/add_vehicle_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_chat_screen.dart';
import '../screens/security/security_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/ride.dart';
import '../models/group.dart';

class AppRoutes {
  // Route names
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
  static const String myVehicles = '/my-vehicles';
  static const String addVehicle = '/add-vehicle';
  static const String wallet = '/wallet';
  static const String groups = '/groups';
  static const String groupChat = '/group-chat';
  static const String security = '/security';
  static const String settings = '/settings';

  // Routes map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),
      dashboard: (context) => const DashboardScreen(),
      searchRides: (context) => const SearchRidesScreen(),
      createRide: (context) => const CreateRideScreen(),
      rideRequests: (context) => const RideRequestsScreen(),
      profile: (context) => const ProfileScreen(),
      myVehicles: (context) => const MyVehiclesScreen(),
      addVehicle: (context) => const AddVehicleScreen(),
      wallet: (context) => const WalletScreen(),
      groups: (context) => const GroupsScreen(),
      security: (context) => const SecurityScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }

  // Generate route for routes with arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case rideDetails:
        final ride = settings.arguments as Ride;
        return MaterialPageRoute(
          builder: (context) => RideDetailsScreen(ride: ride),
        );

      case groupChat:
        final group = settings.arguments as Group;
        return MaterialPageRoute(
          builder: (context) => GroupChatScreen(group: group),
        );

      default:
        return null;
    }
  }
}