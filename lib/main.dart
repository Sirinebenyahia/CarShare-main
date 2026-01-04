import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

// CONFIG
import 'config/theme.dart';
import 'config/routes.dart';

// PROVIDERS
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/group_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/ride_request_provider.dart';
import 'providers/ride_chat_provider.dart';

// FIREBASE TEST (DEV ONLY)
import 'services/firebase_test.dart';

Future<void> main() async {
  /// OBLIGATOIRE pour Firebase
  WidgetsFlutterBinding.ensureInitialized();

  /// INITIALISATION FIREBASE
  await Firebase.initializeApp();

  /// TEST FIREBASE (à garder en DEV seulement)
  await FirebaseTest.testConnection();

  /// FORMAT DATE FR
  await initializeDateFormatting('fr_FR', null);

  runApp(const CarShareTunisie());
}

class CarShareTunisie extends StatelessWidget {
  const CarShareTunisie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// AUTH & USER
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),

        /// CORE FEATURES
        ChangeNotifierProvider<RideProvider>(
          create: (_) => RideProvider(),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider<VehicleProvider>(
          create: (_) => VehicleProvider(),
        ),
        ChangeNotifierProvider<RideChatProvider>(
          create: (_) => RideChatProvider(),
        ),

        /// SOCIAL / GROUPS
        ChangeNotifierProvider<GroupProvider>(
          create: (_) => GroupProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),

        /// REQUESTS & WALLET
        ChangeNotifierProvider<RideRequestProvider>(
          create: (_) => RideRequestProvider(),
        ),
        ChangeNotifierProvider<WalletProvider>(
          create: (_) => WalletProvider(),
        ),
      ],

      /// ON ÉCOUTE L'ÉTAT AUTH GLOBAL
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'CarShare Tunisie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,

            /// ROUTING CENTRALISÉ
            initialRoute: authProvider.isAuthenticated
                ? AppRoutes.dashboard
                : AppRoutes.login,

            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
