import 'package:flutter/material.dart';
import '../models/group.dart';

class ChatProvider with ChangeNotifier {
  Map<String, List<ChatMessage>> _groupMessages = {};
  bool _isLoading = false;

  List<ChatMessage> getMessages(String groupId) {
    return _groupMessages[groupId] ?? [];
  }

  bool get isLoading => _isLoading;

  Future<void> fetchMessages(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock messages
      if (!_groupMessages.containsKey(groupId)) {
        _groupMessages[groupId] = [
          ChatMessage(
            id: '1',
            groupId: groupId,
            senderId: '2',
            senderName: 'Ahmed',
            message: 'Bonjour à tous!',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: '2',
            groupId: groupId,
            senderId: '3',
            senderName: 'Salma',
            message: 'Salut! Quelqu\'un part pour Sfax demain?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    String? senderImageUrl,
    required String message,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        senderId: senderId,
        senderName: senderName,
        senderImageUrl: senderImageUrl,
        message: message,
        timestamp: DateTime.now(),
      );

      if (!_groupMessages.containsKey(groupId)) {
        _groupMessages[groupId] = [];
      }

      _groupMessages[groupId]!.add(newMessage);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearMessages(String groupId) {
    _groupMessages.remove(groupId);
    notifyListeners();
  }

  void initialize() {
    // Removed loadChatRooms();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
