import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/ride.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_chat_provider.dart';
import 'ride_chat_screen.dart';

class RideDiscussionsScreen extends StatelessWidget {
  final String? rideId;

  const RideDiscussionsScreen({Key? key, this.rideId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final userId = user?.id;
    final isDriver = user?.role == UserRole.driver;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: isDriver
            ? context.read<RideChatProvider>().streamDriverConversations(userId, rideId: rideId)
            : context.read<RideChatProvider>().streamPassengerConversations(userId, rideId: rideId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Aucune discussion'),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final chatId = docs[index].id;
              final chatRideId = (data['rideId'] as String?) ?? '';
              final passengerId = (data['passengerId'] as String?) ?? '';
              final driverId = (data['driverId'] as String?) ?? '';
              final title = (data['rideTitle'] as String?)?.trim();
              final lastMessage = (data['lastMessage'] as String?)?.trim();
              final ts = data['lastTimestamp'];
              final passengerName = (data['passengerName'] as String?)?.trim();

              DateTime? lastTime;
              if (ts is Timestamp) lastTime = ts.toDate();

              final subtitle = (lastMessage != null && lastMessage.isNotEmpty)
                  ? lastMessage
                  : 'Ouvrir la discussion';

              final tileTitle = isDriver
                  ? (passengerName?.isNotEmpty == true ? passengerName! : (title?.isNotEmpty == true ? title! : chatRideId))
                  : (title?.isNotEmpty == true ? title! : chatRideId);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryBlue),
                ),
                title: Text(tileTitle),
                subtitle: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: lastTime == null
                    ? const Icon(Icons.chevron_right)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${lastTime.hour.toString().padLeft(2, '0')}:${lastTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                onTap: () {
                  final ride = Ride(
                    id: chatRideId,
                    driverId: data['driverId'] as String? ?? '',
                    driverName: data['driverName'] as String? ?? '',
                    driverImageUrl: data['driverImageUrl'] as String? ?? '',
                    driverRating: (data['driverRating'] as num?)?.toDouble() ?? 0.0,
                    fromCity: data['fromCity'] as String? ?? '',
                    toCity: data['toCity'] as String? ?? '',
                    departureDate: data['departureDate'] is Timestamp 
                        ? (data['departureDate'] as Timestamp).toDate()
                        : DateTime.now(),
                    departureTime: data['departureTime'] != null
                        ? TimeOfDay(
                            hour: data['departureTime']['hour'] as int,
                            minute: data['departureTime']['minute'] as int,
                          )
                        : const TimeOfDay(hour: 8, minute: 0),
                    pricePerSeat: (data['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
                    availableSeats: (data['availableSeats'] as num?)?.toInt() ?? 1,
                    totalSeats: (data['totalSeats'] as num?)?.toInt() ?? 1,
                    description: data['description'] as String?,
                    status: RideStatus.values.firstWhere(
                      (e) => e.toString() == 'RideStatus.${data['status']}',
                      orElse: () => RideStatus.active,
                    ),
                    createdAt: data['createdAt'] is Timestamp
                        ? (data['createdAt'] as Timestamp).toDate()
                        : DateTime.now(),
                    updatedAt: data['updatedAt'] is Timestamp
                        ? (data['updatedAt'] as Timestamp).toDate()
                        : null,
                    vehicleId: data['vehicleId'] as String?,
                    vehicleInfo: data['vehicleInfo'] as Map<String, dynamic>?,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideChatScreen(
                        ride: ride,
                        chatId: chatId,
                        passengerId: passengerId,
                        driverId: driverId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
