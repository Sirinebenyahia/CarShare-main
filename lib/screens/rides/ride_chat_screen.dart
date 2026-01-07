import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../models/ride_message.dart';
import '../../providers/ride_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == user?.id;
                    return ListTile(
                      leading: msg.senderImageUrl != null 
                          ? CircleAvatar(backgroundImage: NetworkImage(msg.senderImageUrl!))
                          : CircleAvatar(
                              child: Text(msg.senderName.isNotEmpty ? msg.senderName.substring(0, 1).toUpperCase() : '?'),
                            ),
                      title: Text(msg.senderName),
                      subtitle: Text(msg.message),
                      trailing: isMe ? const Icon(Icons.person) : null,
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
