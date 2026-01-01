import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/ride_service.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key, required this.rideId});

  final String rideId;

  static final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _rideService.rideStream(rideId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Trajet introuvable.'),
            );
          }

          final from = (data['from'] ?? '').toString();
          final to = (data['to'] ?? '').toString();
          final seats = data['seatsAvailable'];
          final womenOnly = (data['womenOnly'] ?? false) == true;
          final price = data['priceTnd'];
          final driverName = (data['driverName'] ?? '').toString();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$from → $to', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Chauffeur: $driverName', style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text('$seats places disponibles', style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        if (womenOnly) const Chip(label: Text('Femmes uniquement')),
                        const SizedBox(height: 8),
                        Text('$price TND', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.go('/payment/$rideId'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Réserver'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
