import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SimpleRidesWidget extends StatelessWidget {
  const SimpleRidesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Création de trajets de test statiques pour contourner les problèmes Firebase
    final testRides = [
      {
        'driverName': 'Mohamed Conductor',
        'fromCity': 'Tunis',
        'toCity': 'Sousse',
        'time': '09:00',
        'price': '12',
        'seats': '2',
        'rating': '4.8',
        'phone': '21612345678',
      },
      {
        'driverName': 'Sami Driver',
        'fromCity': 'Tunis',
        'toCity': 'Sfax',
        'time': '14:30',
        'price': '18',
        'seats': '1',
        'rating': '4.2',
        'phone': '21698765432',
      },
      {
        'driverName': 'Leila Pilot',
        'fromCity': 'Sousse',
        'toCity': 'Sfax',
        'time': '11:15',
        'price': '10',
        'seats': '3',
        'rating': '4.9',
        'phone': '21655555555',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trajets disponibles (${testRides.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité de recherche bientôt disponible')),
                );
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: testRides.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ride = testRides[index];
            return _buildSimpleRideCard(context, ride);
          },
        ),
      ],
    );
  }

  Widget _buildSimpleRideCard(BuildContext context, Map<String, String> ride) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    ride['driverName']![0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride['driverName']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            ride['rating']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Appel de ${ride['driverName']} au ${ride['phone']}'),
                        action: SnackBarAction(
                          label: 'Appeler',
                          onPressed: () {
                            // Simuler l'appel
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Appel vers ${ride['phone']}...')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, color: Colors.green),
                  tooltip: 'Appeler le conducteur',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Départ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ride['fromCity']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.primaryBlue),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Arrivée',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ride['toCity']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      ride['time']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.event_seat, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${ride['seats']} places',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  '${ride['price']} TND/place',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité de réservation bientôt disponible')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réserver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
