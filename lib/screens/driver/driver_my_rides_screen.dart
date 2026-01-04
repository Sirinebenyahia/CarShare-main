import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/ride.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/rides/edit_ride_screen.dart';
import '../../config/routes.dart';

class DriverMyRidesScreen extends StatefulWidget {
  const DriverMyRidesScreen({Key? key}) : super(key: key);

  @override
  State<DriverMyRidesScreen> createState() => _DriverMyRidesScreenState();
}

class _DriverMyRidesScreenState extends State<DriverMyRidesScreen> {
  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    print('🚗 DriverMyRides: _loadRides appelé');
    final user = context.read<AuthProvider>().currentUser;
    print('🚗 DriverMyRides: User ID: ${user?.id}');
    
    if (user != null) {
      print('🚗 DriverMyRides: Appel de fetchMyRides...');
      await context.read<RideProvider>().fetchMyRides(user.id);
      print('🚗 DriverMyRides: fetchMyRides terminé');
      
      final rides = context.read<RideProvider>().myRides;
      print('🚗 DriverMyRides: Nombre de trajets: ${rides.length}');
    } else {
      print('🚗 DriverMyRides: User est null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes trajets'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRides,
          ),
        ],
      ),
      body: Consumer<RideProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = provider.myRides;
          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun trajet publié',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Commencez par publier votre premier trajet',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.createRide);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Publier un trajet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRides,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return _buildRideCard(ride);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createRide);
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${ride.fromCity} → ${ride.toCity}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(ride.status),
              ],
            ),
            const SizedBox(height: 12),
            
            // Date and time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${ride.departureDate.day}/${ride.departureDate.month}/${ride.departureDate.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${ride.departureTime.hour.toString().padLeft(2, '0')}:${ride.departureTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Price and seats
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${ride.pricePerSeat.toInt()} TND/place',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${ride.availableSeats}/${ride.totalSeats} places',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            
            // Description (if any)
            if (ride.description != null && ride.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ride.description!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            
            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRideScreen(ride: ride),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadRides(); // Refresh if ride was updated or deleted
                        }
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRideDetails(ride);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Détails'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(RideStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case RideStatus.active:
        color = Colors.green;
        text = 'Actif';
        break;
      case RideStatus.completed:
        color = Colors.grey;
        text = 'Terminé';
        break;
      case RideStatus.cancelled:
        color = Colors.red;
        text = 'Annulé';
        break;
      default:
        color = Colors.blue;
        text = status.toString().split('.').last;
    }
    
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showRideDetails(Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails du trajet'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Itinéraire: ${ride.fromCity} → ${ride.toCity}'),
              const SizedBox(height: 8),
              Text('Date: ${ride.departureDate.day}/${ride.departureDate.month}/${ride.departureDate.year}'),
              const SizedBox(height: 8),
              Text('Heure: ${ride.departureTime.hour.toString().padLeft(2, '0')}:${ride.departureTime.minute.toString().padLeft(2, '0')}'),
              const SizedBox(height: 8),
              Text('Prix: ${ride.pricePerSeat.toInt()} TND/place'),
              const SizedBox(height: 8),
              Text('Places: ${ride.availableSeats}/${ride.totalSeats}'),
              if (ride.description != null && ride.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(ride.description!),
              ],
              const SizedBox(height: 8),
              Text('Créé le: ${ride.createdAt.day}/${ride.createdAt.month}/${ride.createdAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRideScreen(ride: ride),
                ),
              ).then((result) {
                if (result == true) {
                  _loadRides();
                }
              });
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }
}
