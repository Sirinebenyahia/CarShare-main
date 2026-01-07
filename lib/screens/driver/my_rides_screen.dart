import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ride.dart';
import '../../config/theme.dart';
import '../../screens/rides/edit_ride_screen.dart';
import 'package:intl/intl.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  @override
  void initState() {
    super.initState();
    _loadMyRides();
  }

  Future<void> _loadMyRides() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      context.read<RideProvider>().listenToMyRides(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes trajets'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, _) {
          if (rideProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final myRides = rideProvider.myRides;

          if (myRides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun trajet créé',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre premier trajet pour commencer',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/create-ride'),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un trajet'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMyRides,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRides.length,
              itemBuilder: (context, index) {
                final ride = myRides[index];
                return _buildRideCard(ride);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: const Icon(
                Icons.directions_car,
                color: AppTheme.primaryBlue,
              ),
            ),
            title: Text(
              '${ride.fromCity} → ${ride.toCity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy', 'fr_FR').format(ride.departureDate),
            ),
            trailing: _buildStatusChip(ride.status.toString()),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        DateFormat('HH:mm', 'fr_FR').format(ride.departureDate),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.people,
                        '${ride.availableSeats} places',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.attach_money,
                        '${ride.pricePerSeat} TND/place',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.directions,
                        ride.preferences?.toString().split('.').last ?? 'Standard',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editRide(ride),
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewProposals(ride),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Voir les demandes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = AppTheme.successGreen;
        label = 'Actif';
        break;
      case 'completed':
        color = AppTheme.primaryBlue;
        label = 'Terminé';
        break;
      case 'cancelled':
        color = AppTheme.errorRed;
        label = 'Annulé';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  void _editRide(Ride ride) {
    // Test temporaire pour vérifier que le bouton fonctionne
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tentative de modification du trajet: ${ride.fromCity} → ${ride.toCity}'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
    
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRideScreen(ride: ride),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de navigation: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _viewProposals(Ride ride) {
    // Naviguer vers l'écran des demandes pour ce trajet
    Navigator.pushNamed(
      context,
      '/ride-requests',
      arguments: {
        'rideId': ride.id,
        'fromCity': ride.fromCity,
        'toCity': ride.toCity,
      },
    );
  }
}
