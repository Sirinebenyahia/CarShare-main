import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ride_request.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({Key? key}) : super(key: key);

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadMyProposals();
  }

  Future<void> _loadMyProposals() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      // Charger manuellement les propositions au lieu d'utiliser le stream
      await context.read<RideRequestProvider>().fetchAllRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes propositions'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RideRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final myProposals = provider.myProposals;

          if (myProposals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune proposition',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faites des propositions sur les demandes des passagers',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/ride-requests'),
                    icon: const Icon(Icons.request_page),
                    label: const Text('Voir les demandes'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMyProposals,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myProposals.length,
              itemBuilder: (context, index) {
                final proposal = myProposals[index];
                return _buildProposalCard(proposal);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProposalCard(RideProposal proposal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                proposal.driverName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Proposition #${proposal.id.substring(0, 6)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(proposal.driverRating.toStringAsFixed(1)),
                  ],
                ),
                Text('${proposal.proposedPrice} TND'),
              ],
            ),
            trailing: _buildStatusChip(proposal.status),
          ),
          if (proposal.message != null && proposal.message!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.message, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      proposal.message!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                        Icons.route,
                        'Demande: ${proposal.requestId.substring(0, 6)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        DateFormat('dd MMM yyyy', 'fr_FR').format(proposal.createdAt),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        DateFormat('HH:mm', 'fr_FR').format(proposal.createdAt),
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

  Widget _buildStatusChip(ProposalStatus status) {
    Color color;
    String label;

    switch (status) {
      case ProposalStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
      case ProposalStatus.accepted:
        color = AppTheme.successGreen;
        label = 'Acceptée';
        break;
      case ProposalStatus.rejected:
        color = AppTheme.errorRed;
        label = 'Refusée';
        break;
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
}
