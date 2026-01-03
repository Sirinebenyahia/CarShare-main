import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatMessage _msgFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = Map<String, dynamic>.from(d.data());
    data['id'] ??= d.id;
    return ChatMessage.fromJson(data);
  }

  // Stream messages for a group (real-time)
  Stream<List<ChatMessage>> streamGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_msgFromDoc).toList());
  }

  // Send a message to a group
  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String message,
    String? senderImageUrl,
  }) async {
    try {
      final ref = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc();

      final msg = ChatMessage(
        id: ref.id,
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        senderImageUrl: senderImageUrl,
        message: message,
        timestamp: DateTime.now(),
      );

      await ref.set({
        'id': msg.id,
        'groupId': msg.groupId,
        'senderId': msg.senderId,
        'senderName': msg.senderName,
        'senderImageUrl': msg.senderImageUrl,
        'message': msg.message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Also update group's lastMessage and updatedAt
      await _firestore.collection('groups').doc(groupId).set(
            {
              'lastMessage': message,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  // Delete a message (owner or admin)
  Future<void> deleteMessage(String groupId, String messageId) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch messages for a group (one-time)
  Future<void> fetchMessages(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _messages = snap.docs.map(_msgFromDoc).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear local messages (e.g., when leaving group)
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
