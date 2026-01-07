import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/ride_request.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_request_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/unread_messages_badge.dart';
import '../../config/routes.dart';
import '../../config/tunisian_cities.dart';
import 'package:intl/intl.dart';

class RideRequestsScreen extends StatefulWidget {
  const RideRequestsScreen({Key? key}) : super(key: key);

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    _isDriver = authProvider.currentUser?.role == UserRole.driver;

    if (_isDriver) {
      await context.read<RideRequestProvider>().fetchAllRequests();
    } else {
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        await context.read<RideRequestProvider>().fetchMyRequests(userId);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isDriver ? 'Demandes de trajets' : 'Mes demandes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: _isDriver ? 'Toutes les demandes' : 'Actives'),
            Tab(text: _isDriver ? 'Mes propositions' : 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isDriver ? _buildAllRequestsTab() : _buildActiveRequestsTab(),
          _isDriver ? _buildMyProposalsTab() : _buildHistoryTab(),
        ],
      ),
      floatingActionButton: !_isDriver
          ? FloatingActionButton.extended(
        onPressed: _showCreateRequestDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
      )
          : null,
    );
  }

  Widget _buildAllRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer<RideRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final activeRequests = provider.allRequests.where((r) => r.status == RideRequestStatus.active).toList();

          if (activeRequests.isEmpty) {
            return _buildEmptyState(
              icon: Icons.search_off,
              title: 'Aucune demande',
              subtitle: 'Aucune demande de trajet disponible pour le moment',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeRequests.length,
            itemBuilder: (context, index) {
              final request = activeRequests[index];
              return _buildRequestCard(request, isDriver: true);
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer<RideRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeRequests = provider.getMyRequestsByStatus(RideRequestStatus.active);

          if (activeRequests.isEmpty) {
            return _buildEmptyState(
              icon: Icons.request_page_outlined,
              title: 'Aucune demande active',
              subtitle: 'Créez une demande pour trouver un trajet',
              actionLabel: 'Créer une demande',
              onAction: _showCreateRequestDialog,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeRequests.length,
            itemBuilder: (context, index) {
              final request = activeRequests[index];
              return _buildRequestCard(request, isDriver: false);
            },
          );
        },
      ),
    );
  }

  Widget _buildMyProposalsTab() {
    return Consumer<RideRequestProvider>(
      builder: (context, provider, _) {
        final requestsWithProposals = provider.allRequests
            .where((req) => req.proposals.isNotEmpty)
            .toList();

        if (requestsWithProposals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.send_outlined,
            title: 'Aucune proposition',
            subtitle: 'Vous n\'avez pas encore fait de proposition',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requestsWithProposals.length,
          itemBuilder: (context, index) {
            final request = requestsWithProposals[index];
            return _buildRequestCard(request, isDriver: true, showProposals: true);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<RideRequestProvider>(
      builder: (context, provider, _) {
        final historyRequests = provider.myRequests
            .where((req) => req.status != RideRequestStatus.active)
            .toList();

        if (historyRequests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'Aucun historique',
            subtitle: 'Vos demandes terminées apparaîtront ici',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyRequests.length,
          itemBuilder: (context, index) {
            final request = historyRequests[index];
            return _buildRequestCard(request, isDriver: false);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(RideRequest request, {required bool isDriver, bool showProposals = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                request.passengerName.isNotEmpty ? request.passengerName.substring(0, 1).toUpperCase() : '?',
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(request.passengerName),
            subtitle: Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(request.passengerRating.toStringAsFixed(1)),
              ],
            ),
            trailing: _buildStatusChip(request.status),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.origin,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppTheme.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.destination,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        DateFormat('dd MMM yyyy', 'fr_FR').format(request.departureDate),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        _formatModelTime(request.departureTime),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.people,
                        '${request.seatsNeeded} place(s)',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.payments,
                        '${request.maxPrice.toStringAsFixed(0)} TND max',
                      ),
                    ),
                  ],
                ),
                if (request.notes != null && request.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.note, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (isDriver && request.status == RideRequestStatus.active)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showProposalDialog(request),
                      icon: const Icon(Icons.send),
                      label: const Text('Faire une proposition'),
                    ),
                  ),
                if (!isDriver && request.status == RideRequestStatus.active)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelRequest(request.id),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Annuler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showProposals(request),
                          icon: const Icon(Icons.visibility),
                          label: Text('Propositions (${request.proposals.length})'),
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

  String _formatModelTime(dynamic time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  Widget _buildStatusChip(RideRequestStatus status) {
    switch (status) {
      case RideRequestStatus.active:
        return const Text('Active', style: TextStyle(color: AppTheme.primaryBlue));
      case RideRequestStatus.accepted:
        return const Text('Accepté', style: TextStyle(color: AppTheme.successGreen));
      case RideRequestStatus.rejected:
        return const Text('Rejeté', style: TextStyle(color: AppTheme.errorRed));
      case RideRequestStatus.completed:
        return const Text('Terminé', style: TextStyle(color: Colors.grey));
      case RideRequestStatus.cancelled:
        return const Text('Annulé', style: TextStyle(color: Colors.grey));
      case RideRequestStatus.matched:
        return const Text('Correspondance', style: TextStyle(color: AppTheme.warningOrange));
      case RideRequestStatus.expired:
        return const Text('Expiré', style: TextStyle(color: Colors.grey));
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateRequestDialog() {
    String? selectedOrigin;
    String? selectedDestination;
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

    int seatsNeeded = 1;
    double maxPrice = 20.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer une demande'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedOrigin,
                  decoration: const InputDecoration(
                    labelText: 'Départ *',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: TunisianCities.cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOrigin = value;
                      if (selectedDestination == value) {
                        selectedDestination = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDestination,
                  decoration: const InputDecoration(
                    labelText: 'Destination *',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: TunisianCities.cities
                      .where((city) => city != selectedOrigin)
                      .map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedDestination = value);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('dd MMM yyyy', 'fr_FR').format(selectedDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: seatsNeeded,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de places *',
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: List.generate(8, (index) => index + 1).map((seats) {
                    return DropdownMenuItem(
                      value: seats,
                      child: Text('$seats place${seats > 1 ? 's' : ''}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => seatsNeeded = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<double>(
                  value: maxPrice,
                  decoration: const InputDecoration(
                    labelText: 'Prix maximum (TND) *',
                    prefixIcon: Icon(Icons.payments),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: [5, 10, 15, 20, 25, 30, 40, 50, 75, 100].map((price) {
                    return DropdownMenuItem(
                      value: price.toDouble(),
                      child: Text('$price TND'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => maxPrice = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedOrigin == null || selectedDestination == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner les villes de départ et d\'arrivée'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                if (selectedOrigin == selectedDestination) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Les villes de départ et d\'arrivée doivent être différentes'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                final user = context.read<AuthProvider>().currentUser;

                final request = RideRequest(
                  id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                  passengerId: user?.id ?? '',
                  passengerName: user?.fullName ?? '',
                  passengerAvatar: user?.profileImageUrl ?? '',
                  passengerRating: user?.rating ?? 0.0,
                  origin: selectedOrigin!,
                  destination: selectedDestination!,
                  departureDate: selectedDate,
                  departureTime: selectedTime,
                  seatsNeeded: seatsNeeded,
                  maxPrice: maxPrice,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                  createdAt: DateTime.now(),
                );

                try {
                  await context.read<RideRequestProvider>().createRequest(request);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demande créée avec succès'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProposalDialog(RideRequest request) {
    final messageController = TextEditingController();
    double proposedPrice = request.maxPrice;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Faire une proposition'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${request.origin} → ${request.destination}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.payments),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Prix: ${proposedPrice.toStringAsFixed(0)} TND'),
                  ),
                  IconButton(
                    onPressed: proposedPrice > 5
                        ? () => setState(() => proposedPrice -= 5)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    onPressed: proposedPrice < request.maxPrice
                        ? () => setState(() => proposedPrice += 5)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message (optionnel)',
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = context.read<AuthProvider>().currentUser;
                final proposal = RideProposal(
                  id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
                  requestId: request.id,
                  driverId: user?.id ?? '',
                  driverName: user?.fullName ?? '',
                  driverAvatar: user?.profileImageUrl ?? '',
                  driverRating: user?.rating ?? 0.0,
                  rideId: 'ride_mock',
                  vehicleName: 'Véhicule',
                  proposedPrice: proposedPrice,
                  message: messageController.text.isNotEmpty
                      ? messageController.text
                      : null,
                  createdAt: DateTime.now(),
                );

                try {
                  await context
                      .read<RideRequestProvider>()
                      .submitProposal(request.id, proposal);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Proposition envoyée avec succès'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProposals(RideRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Propositions (${request.proposals.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: request.proposals.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune proposition pour le moment',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: request.proposals.length,
                itemBuilder: (context, index) {
                  final proposal = request.proposals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
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
                      title: Text(proposal.driverName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(proposal.driverRating.toStringAsFixed(1)),
                            ],
                          ),
                          Text('${proposal.proposedPrice} TND'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _acceptProposal(request.id, proposal.id),
                        child: const Text('Accepter'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptProposal(String requestId, String proposalId) async {
    try {
      await context.read<RideRequestProvider>().acceptProposal(requestId, proposalId);
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposition acceptée !'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await context.read<RideRequestProvider>().cancelRequest(requestId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }
}
