import 'package:flutter/material.dart';
import '../../models/ride.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class RideCardSimple extends StatelessWidget {
  final Ride ride;

  const RideCardSimple({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy', 'fr_FR').format(ride.departureDate),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm', 'fr_FR').format(ride.departureDate),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${ride.pricePerSeat} TND/place',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.event_seat, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${ride.availableSeats} places',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                ride.status.name.toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: _getStatusColor(ride.status),
              padding: EdgeInsets.zero,
            ),
          ),
          
          // Driver and Vehicle Info
          if (ride.vehicleInfo != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: ride.vehicleInfo!['driverInfo']?['avatar'] != null 
                            ? NetworkImage(ride.vehicleInfo!['driverInfo']!['avatar'])
                            : null,
                        child: ride.vehicleInfo!['driverInfo']?['avatar'] != null 
                            ? const SizedBox.shrink()
                            : Text(
                                ride.vehicleInfo!['driverInfo']?['name']?.substring(0, 1).toUpperCase() ?? 'D',
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
                              ride.vehicleInfo!['driverInfo']?['name'] ?? 'Conducteur',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${ride.vehicleInfo!['driverInfo']?['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            if (ride.vehicleInfo!['driverInfo']?['phone'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    ride.vehicleInfo!['driverInfo']?['phone'] ?? '',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Vehicle Info
                  if (ride.vehicleInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Véhicule: ${ride.vehicleInfo!['brand'] ?? 'N/A'} ${ride.vehicleInfo!['model'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Année: ${ride.vehicleInfo!['year'] ?? 'N/A'} | Places: ${ride.availableSeats}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.active:
        return AppTheme.successGreen;
      case RideStatus.completed:
        return AppTheme.primaryBlue;
      case RideStatus.cancelled:
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }
}
