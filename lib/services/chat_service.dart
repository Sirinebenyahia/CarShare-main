import '../models/message.dart';

class ChatService {
  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String text,
  }) async {
    throw UnimplementedError();
  }

  Stream<List<Message>> getMessages(String userId1, String userId2) {
    return const Stream.empty();
  }

  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return const Stream.empty();
  }

  Future<void> markMessageAsRead(String messageId) async {
    throw UnimplementedError();
  }

  Stream<int> getUnreadMessagesCount(String userId) {
    return const Stream.empty();
  }

  Future<void> deleteMessage(String messageId) async {
    throw UnimplementedError();
  }

  Future<void> sendMessageWithImage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String text,
    required String imageUrl,
  }) async {
    throw UnimplementedError();
  }
}
