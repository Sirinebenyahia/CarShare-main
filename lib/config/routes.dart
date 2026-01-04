import 'package:flutter/material.dart';

// AUTH
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/role_selection_screen.dart';

// DASHBOARD
import '../screens/dashboard/dashboard_screen.dart';

// DRIVER
import '../screens/driver/driver_my_rides_screen.dart';

// RIDES
import '../screens/rides/search_rides_screen.dart';
import '../screens/rides/create_ride_screen.dart';
import '../screens/rides/edit_ride_screen.dart';
import '../screens/rides/ride_details_screen.dart';
import '../screens/rides/ride_chat_screen.dart';
import '../screens/rides/ride_discussions_screen.dart';

// REQUESTS
import '../screens/ride_requests_screen.dart';
import '../screens/requests/create_request_screen.dart';
import '../screens/requests/my_requests_screen.dart';

// PROFILE
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

// VERIFICATION
import '../screens/verification/id_verification_screen.dart';
import '../screens/verification/license_verification_screen.dart';

// REVIEWS
import '../screens/reviews/reviews_screen.dart';
import '../screens/driver/my_rides_screen.dart';
import '../screens/driver/simple_proposals_screen.dart';
import '../screens/vehicle/my_vehicles_screen.dart';
import '../screens/vehicle/add_vehicle_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_chat_screen.dart';
import '../screens/security/security_screen.dart';
import '../screens/settings/settings_screen.dart';

// MODELS (for arguments)
import '../models/ride.dart';
import '../models/group.dart';
import '../screens/rides/ride_chat_screen.dart';

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
  static const String editRide = '/edit-ride';
  static const String rideDetails = '/ride-details';
  static const String rideChat = '/ride-chat';
  static const String rideDiscussions = '/ride-discussions';

  static const String rideRequests = '/ride-requests';
  static const String createRequest = '/create-request';
  static const String myRequests = '/my-requests';

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String idVerification = '/id-verification';
  static const String licenseVerification = '/license-verification';
  static const String reviews = '/reviews';
  static const String myRides = '/my-rides';
  static const String driverMyRides = '/driver-my-rides';
  static const String myProposals = '/my-proposals';
  static const String simpleProposals = '/simple-proposals';
  static const String myVehicles = '/my-vehicles';
  static const String addVehicle = '/add-vehicle';
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
    editRide: (_) => throw UnimplementedError('editRide route requires ride parameter'),
    rideDiscussions: (_) => const RideDiscussionsScreen(),
    rideRequests: (_) => const RideRequestsScreen(),
    createRequest: (_) => const CreateRequestScreen(),
    myRequests: (_) => const MyRequestsScreen(),

    profile: (_) => const ProfileScreen(),
    editProfile: (_) => const EditProfileScreen(),
    idVerification: (_) => const IdVerificationScreen(),
    licenseVerification: (_) => const LicenseVerificationScreen(),
    reviews: (_) => const ReviewsScreen(),
    myRides: (_) => const MyRidesScreen(),
    driverMyRides: (_) => const DriverMyRidesScreen(),
    // myProposals: (_) => const MyProposalsScreen(), // Commenté pour l'instant
    simpleProposals: (_) => const SimpleProposalsScreen(),
    myVehicles: (_) => const MyVehiclesScreen(),
    addVehicle: (_) => const AddVehicleScreen(),
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

      case rideChat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RideChatScreen(
            ride: args['ride'],
            chatId: args['chatId'],
            passengerId: args['passengerId'],
            driverId: args['driverId'],
          ),
        );

      case editRide:
        final ride = settings.arguments as Ride;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EditRideScreen(ride: ride),
        );

      default:
        return null;
    }
  }
}
