import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../models/ride_message.dart';

class RideChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId({required String rideId, required String passengerId}) {
    return '${rideId}_$passengerId';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPassengerConversations(String passengerId, {String? rideId}) {
    Query<Map<String, dynamic>> q = _firestore
        .collection('ride_chats')
        .where('passengerId', isEqualTo: passengerId);
    if (rideId != null && rideId.isNotEmpty) {
      q = q.where('rideId', isEqualTo: rideId);
    }
    return q.orderBy('lastTimestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDriverConversations(String driverId, {String? rideId}) {
    Query<Map<String, dynamic>> q = _firestore
        .collection('ride_chats')
        .where('driverId', isEqualTo: driverId);
    if (rideId != null && rideId.isNotEmpty) {
      q = q.where('rideId', isEqualTo: rideId);
    }
    return q.orderBy('lastTimestamp', descending: true).snapshots();
  }

  Stream<List<RideMessage>> streamMessages(String chatId) {
    final coll = _firestore.collection('ride_chats').doc(chatId).collection('messages').orderBy('timestamp');
    return coll.snapshots().map((snap) => snap.docs.map((d) {
      final data = d.data();
      return RideMessage(
        id: d.id,
        rideId: (data['rideId'] as String?) ?? '',
        senderId: data['senderId'] as String,
        senderName: data['senderName'] as String,
        senderImageUrl: data['senderImageUrl'] as String?,
        message: data['message'] as String,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String rideId,
    required String passengerId,
    required String driverId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String message,
    Ride? ride,
    String? passengerName,
    String? passengerImageUrl,
  }) async {
    final chatRef = _firestore.collection('ride_chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');

    final batch = _firestore.batch();

    batch.set(
      chatRef,
      {
        'chatId': chatId,
        'rideId': rideId,
        'passengerId': passengerId,
        'driverId': driverId,
        'participants': [passengerId, driverId],
        if (passengerName != null) 'passengerName': passengerName,
        if (passengerImageUrl != null) 'passengerImageUrl': passengerImageUrl,
        if (ride != null) ...{
          'rideTitle': '${ride.fromCity} → ${ride.toCity} (${ride.departureTime})',
          'driverName': ride.driverName,
          'driverImageUrl': ride.driverImageUrl,
          'driverRating': ride.driverRating,
          'fromCity': ride.fromCity,
          'toCity': ride.toCity,
          'departureDate': ride.departureDate.toIso8601String(),
          'departureTime': ride.departureTime,
          'availableSeats': ride.availableSeats,
          'totalSeats': ride.totalSeats,
          'pricePerSeat': ride.pricePerSeat,
          'vehicleId': ride.vehicleId,
        },
        'lastMessage': message,
        'lastSenderId': senderId,
        'lastTimestamp': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      messagesRef.doc(),
      {
        'rideId': rideId,
        'senderId': senderId,
        'senderName': senderName,
        'senderImageUrl': senderImageUrl,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }
}
