import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<RideRequestProvider>().fetchMyRequests(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('my_requests')),
      ),
      body: Consumer<RideRequestProvider>(
        builder: (context, requestProvider, _) {
          if (requestProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestProvider.myRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.request_page,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.t('no_requests'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.t('no_requests_subtitle'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requestProvider.myRequests.length,
            itemBuilder: (context, index) {
              final request = requestProvider.myRequests[index];
              return _buildRequestCard(request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(request) {
    Color statusColor;
    String statusText;
    switch (request.status) {
      case 'pending':
        statusColor = AppTheme.warningOrange;
        statusText = 'En attente';
        break;
      case 'accepted':
        statusColor = AppTheme.successGreen;
        statusText = 'Acceptée';
        break;
      case 'rejected':
        statusColor = AppTheme.errorRed;
        statusText = 'Refusée';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnue';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.directions_car,
            color: statusColor,
          ),
        ),
        title: Text(
          '${request.departure} → ${request.destination}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          request.departureDate?.toString().split(' ')[0] ?? '',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          statusText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        onTap: () {
          // TODO: Navigate to request details
        },
      ),
    );
  }
}
