import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service gérant les notifications push FCM
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialise FCM : permissions, token, handlers
  Future<void> initialize() async {
    // Demander la permission
    await _requestPermission();

    // Récupérer le token
    await _getToken();

    // Handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Synchroniser le token à chaque refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permission: ${settings.authorizationStatus}');
  }

  Future<void> _getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      await _syncTokenToFirestore(token);
    } catch (e) {
      debugPrint('Erreur getToken FCM: $e');
    }
  }

  Future<void> _onTokenRefresh(String? token) async {
    if (token == null) return;
    debugPrint('FCM Token refreshed: $token');
    await _syncTokenToFirestore(token);
  }

  Future<void> _syncTokenToFirestore(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
        'token': token,
        'platform': Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erreur syncTokenToFirestore: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Message reçu en foreground: ${message.notification?.title}');
    // Ici on peut afficher une notification locale ou un SnackBar
    // Exemple : afficher un SnackBar dans le contexte actuel
    _showSnackBar(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message ouvert depuis app: ${message.notification?.title}');
    // Naviguer vers la bonne page selon le type
    _navigateToScreen(message);
  }

  void _showSnackBar(RemoteMessage message) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.notification?.body ?? 'Notification reçue'),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () => _navigateToScreen(message),
        ),
      ),
    );
  }

  void _navigateToScreen(RemoteMessage message) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final type = message.data['type'];
    switch (type) {
      case 'booking_created':
      case 'booking_accepted':
        Navigator.pushNamed(context, '/my-bookings');
        break;
      case 'ride_chat_message':
        final chatId = message.data['chatId'];
        if (chatId != null) {
          Navigator.pushNamed(context, '/ride-chat', arguments: chatId);
        }
        break;
      case 'group_message':
        final groupId = message.data['groupId'];
        if (groupId != null) {
          Navigator.pushNamed(context, '/group-chat', arguments: groupId);
        }
        break;
      case 'ride_request_accepted':
        Navigator.pushNamed(context, '/my-requests');
        break;
      default:
        Navigator.pushNamed(context, '/dashboard');
    }
  }

  /// GlobalKey global pour accéder au navigator depuis les handlers
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Message reçu en background: ${message.notification?.title}');
}
