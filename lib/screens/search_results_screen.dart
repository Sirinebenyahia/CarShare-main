import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/ride_service.dart';
import '../widgets/back_button.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    super.key,
    required this.from,
    required this.to,
  });

  final String from;
  final String to;

  static final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    final String fromQuery = from.trim();
    final String toQuery = to.trim();

    return Scaffold(
      appBar: AppBarWithBack(
        title: 'Résultats',
        fallbackRoute: '/home', // Retour à l'accueil
      ),
      body: Padding(
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
                    const Text('Votre recherche', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Départ: $fromQuery'),
                    Text('Arrivée: $toQuery'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _rideService.searchRidesStream(from: fromQuery, to: toQuery),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('Aucun trajet trouvé.'));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final data = d.data();
                      final from = (data['from'] ?? '').toString();
                      final to = (data['to'] ?? '').toString();
                      final driverName = (data['driverName'] ?? '').toString();
                      final price = data['priceTnd'];
                      final seats = data['seatsAvailable'];
                      final womenOnly = (data['womenOnly'] ?? false) == true;

                      return InkWell(
                        onTap: () => context.go('/ride/${d.id}'),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircleAvatar(child: Icon(Icons.person)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$from → $to', style: const TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Text(driverName, style: const TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      Text('${seats ?? ''} places', style: const TextStyle(color: Colors.black54)),
                                      if (womenOnly) ...[
                                        const SizedBox(height: 6),
                                        const Chip(label: Text('Femmes uniquement')),
                                      ],
                                    ],
                                  ),
                                ),
                                Text('${price ?? ''} TND', style: const TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
