import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/group_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/ride_request_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 3. OBLIGATOIRE AVANT D'EXÉCUTER DU CODE ASYNC DANS LE MAIN
  WidgetsFlutterBinding.ensureInitialized();

  // 4. ON INITIALISE LE FORMAT FRANÇAIS
  await initializeDateFormatting('fr_FR', null);

  runApp(const CarShareTunisie());
}

class CarShareTunisie extends StatelessWidget {
  const CarShareTunisie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RideRequestProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'CarShare Tunisie',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: authProvider.isAuthenticated 
                ? const DashboardScreen() 
                : const LoginScreen(),
            routes: AppRoutes.getRoutes(),
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}