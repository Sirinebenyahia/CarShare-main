import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/ride_request.dart';
import '../../providers/ride_request_provider.dart';
import '../../providers/auth_provider.dart';

class RideRequestsScreen extends StatefulWidget {
  const RideRequestsScreen({Key? key}) : super(key: key);

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de trajet'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RideRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = provider.allRequests;
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.request_page, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune demande', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('De ${request.origin} à ${request.destination}'),
                  subtitle: Text('Prix: ${request.maxPrice} TND'),
                  trailing: Chip(
                    label: Text(request.status.toString().split('.').last),
                    backgroundColor: _getStatusColor(request.status),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(RideRequestStatus status) {
    switch (status) {
      case RideRequestStatus.active:
        return Colors.blue;
      case RideRequestStatus.accepted:
        return Colors.green;
      case RideRequestStatus.completed:
        return Colors.grey;
      case RideRequestStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}