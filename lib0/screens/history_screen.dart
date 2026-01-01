import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav.dart';
import '../services/ride_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: user == null
          ? const Center(child: Text('Veuillez vous connecter.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _rideService.myBookingsStream(uid: user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Aucun historique pour le moment.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data();
                    final status = (data['status'] ?? '').toString();
                    final rideId = (data['rideId'] ?? '').toString();

                    return Card(
                      child: ListTile(
                        onTap: () => context.go('/booking/${d.id}'),
                        title: Text('Booking: $rideId'),
                        subtitle: Text('Status: $status'),
                        trailing: const Text('Terminé'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
