import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../models/ride_message.dart';
import '../../providers/ride_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class RideChatScreen extends StatefulWidget {
  final Ride ride;
  final String chatId;
  final String passengerId;
  final String driverId;

  const RideChatScreen({
    Key? key,
    required this.ride,
    required this.chatId,
    required this.passengerId,
    required this.driverId,
  }) : super(key: key);

  @override
  State<RideChatScreen> createState() => _RideChatScreenState();
}

class _RideChatScreenState extends State<RideChatScreen> {
  final _controller = TextEditingController();

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    await context.read<RideChatProvider>().sendMessage(
          chatId: widget.chatId,
          rideId: widget.ride.id,
          passengerId: widget.passengerId,
          driverId: widget.driverId,
          senderId: user.id,
          senderName: user.fullName,
          senderImageUrl: user.profileImageUrl,
          message: text,
          ride: widget.ride,
          passengerName: user.id == widget.passengerId ? user.fullName : null,
          passengerImageUrl: user.id == widget.passengerId ? user.profileImageUrl : null,
        );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isDriver = user?.id == widget.driverId;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ride.fromCity} → ${widget.ride.toCity}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<RideMessage>>(
              stream: context.read<RideChatProvider>().streamMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }
                return ListView.builder(
                  reverse: false,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == user?.id;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                              backgroundImage: msg.senderImageUrl != null 
                                  ? NetworkImage(msg.senderImageUrl!)
                                  : null,
                              child: msg.senderImageUrl == null
                                  ? Text(
                                      msg.senderName.isNotEmpty 
                                          ? msg.senderName.substring(0, 1).toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isMe 
                                        ? AppTheme.primaryBlue 
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Text(
                                          msg.senderName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isMe ? Colors.white : Colors.grey[700],
                                          ),
                                        ),
                                      Text(
                                        msg.message,
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(msg.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                              backgroundImage: user?.profileImageUrl != null 
                                  ? NetworkImage(user!.profileImageUrl!)
                                  : null,
                              child: user?.profileImageUrl == null
                                  ? Text(
                                      user?.fullName.isNotEmpty == true
                                          ? user!.fullName.substring(0, 1).toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _send, 
                    icon: const Icon(Icons.send)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
