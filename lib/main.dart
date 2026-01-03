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
import 'providers/ride_chat_provider.dart';
import 'providers/ride_request_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/fcm_service.dart';

void main() async {
  // 3. OBLIGATOIRE AVANT D'EXÉCUTER DU CODE ASYNC DANS LE MAIN
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM service
  await FcmService().initialize();

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
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, authProvider, userProvider) {
            final up = userProvider ?? UserProvider();
            final user = authProvider.currentUser;
            if (user != null) {
              up.setUser(user);
            } else {
              up.clearUser();
            }
            return up;
          },
        ),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RideChatProvider()),
        ChangeNotifierProvider(create: (_) => RideRequestProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<AuthProvider, LocaleProvider>(
        builder: (context, authProvider, localeProvider, _) {
          return MaterialApp(
            navigatorKey: FcmService.navigatorKey,
            title: 'CarShare Tunisie',
            theme: AppTheme.lightTheme,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('fr'), Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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