import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/ride_chat_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UnreadMessagesBadge extends StatelessWidget {
  final String rideId;
  final String? passengerId;
  final String? driverId;

  const UnreadMessagesBadge({
    Key? key,
    required this.rideId,
    this.passengerId,
    this.driverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    
    if (user == null) return const SizedBox.shrink();

    // Déterminer si l'utilisateur est conducteur ou passager
    final isDriver = user.id == driverId;
    final targetPassengerId = isDriver ? passengerId : user.id;
    final targetDriverId = isDriver ? user.id : driverId;

    if (targetPassengerId == null || targetDriverId == null) {
      return const SizedBox.shrink();
    }

    final chatId = context.read<RideChatProvider>().getChatId(
      rideId: rideId,
      passengerId: targetPassengerId,
    );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('ride_chats')
          .doc(chatId)
          .collection('messages')
          .where('timestamp', isGreaterThan: _getLastReadTimestamp(chatId, user.id))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final unreadMessages = snapshot.data!.docs.where((doc) {
          final messageSenderId = doc.data()['senderId'] as String?;
          return messageSenderId != user.id; // Ne pas compter ses propres messages
        }).length;

        if (unreadMessages == 0) return const SizedBox.shrink();

        return Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              unreadMessages > 99 ? '99+' : unreadMessages.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  // Récupérer le dernier timestamp de lecture pour l'utilisateur
  Timestamp _getLastReadTimestamp(String chatId, String userId) {
    // Pour l'instant, retourner un timestamp ancien
    // Dans une implémentation complète, il faudrait stocker et récupérer
    // le dernier timestamp de lecture de l'utilisateur
    return Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30)));
  }
}
