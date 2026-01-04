import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/ride_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class RideDiscussionsScreen extends StatelessWidget {
  const RideDiscussionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Discussions'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Veuillez vous connecter'),
        ),
      );
    }

    final isDriver = user.role == UserRole.driver;
    final userId = user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDriver ? 'Discussions avec les passagers' : 'Discussions avec les conducteurs'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: isDriver
            ? context.read<RideChatProvider>().streamDriverConversations(userId)
            : context.read<RideChatProvider>().streamPassengerConversations(userId),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des discussions...'),
                ],
              ),
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Aucune discussion pour le moment',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les discussions apparaîtront ici lorsque vous aurez des trajets actifs',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Handle empty state
          final docs = snapshot.data?.docs ?? const [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isDriver ? 'Aucune discussion avec les passagers' : 'Aucune discussion',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Les discussions apparaîtront ici dès que vous commencerez à échanger',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(
                      isDriver ? Icons.person : Icons.directions_car,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    isDriver 
                        ? (data['passengerName'] as String? ?? 'Passager')
                        : (data['driverName'] as String? ?? 'Conducteur'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${data['fromCity']} → ${data['toCity']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    '${data['proposedPrice']} TND',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Naviguer vers le chat
                    Navigator.pushNamed(
                      context,
                      '/ride-chat',
                      arguments: {
                        'chatId': doc.id,
                        'rideId': data['rideId'],
                        'driverId': data['driverId'],
                        'passengerId': data['passengerId'],
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
