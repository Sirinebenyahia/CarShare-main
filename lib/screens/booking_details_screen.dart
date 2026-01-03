import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/ride_service.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.bookingId});

  final String bookingId;

  static final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails réservation')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _rideService.bookingStream(bookingId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final booking = snap.data!.data();
          if (booking == null) {
            return const Center(child: Text('Réservation introuvable.'));
          }

          final rideId = (booking['rideId'] ?? '').toString();
          final status = (booking['status'] ?? '').toString();
          final method = (booking['paymentMethod'] ?? '').toString();
          final createdAt = booking['createdAt'];

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
                        const Text('Réservation', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Statut: $status'),
                        Text('Paiement: $method'),
                        Text('Créée: ${createdAt is Timestamp ? createdAt.toDate().toString() : ''}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _rideService.rideStream(rideId),
                      builder: (context, rideSnap) {
                        if (rideSnap.hasError) {
                          return Text('Erreur trajet: ${rideSnap.error}', style: const TextStyle(color: Colors.red));
                        }
                        if (!rideSnap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final ride = rideSnap.data!.data();
                        if (ride == null) {
                          return const Text('Trajet introuvable.');
                        }
                        final from = (ride['from'] ?? '').toString();
                        final to = (ride['to'] ?? '').toString();
                        final driverName = (ride['driverName'] ?? '').toString();
                        final price = ride['priceTnd'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trajet', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('$from → $to'),
                            Text('Chauffeur: $driverName'),
                            Text('Prix: ${price ?? ''} TND'),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/ride/$rideId'),
                              child: const Text('Voir le trajet'),
                            ),
                          ],
                        );
                      },
                    ),
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
