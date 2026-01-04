import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/ride_request_provider.dart';
import '../../widgets/ride/ride_card.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../screens/driver/my_rides_screen.dart';
import '../../screens/vehicle/my_vehicles_screen.dart';
import '../../screens/rides/edit_ride_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      await context.read<RideProvider>().fetchMyRides(userId);
      await context.read<WalletProvider>().fetchBalance(userId);
      await context.read<VehicleProvider>().fetchMyVehicles(userId);
      await context.read<BookingProvider>().fetchAcceptedRequests(userId);
      await context.read<RideRequestProvider>().fetchAllRequests();
      // Désactiver le stream des propositions pour éviter le blocage
      // context.read<RideRequestProvider>().listenToMyProposals(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarShare Tunisie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotifications();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-ride');
        },
        icon: const Icon(Icons.add),
        label: const Text('Publier'),
      )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                ),
                accountName: Text(user?.fullName ?? ''),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: user?.profileImageUrl != null
                      ? null
                      : Text(
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Mon profil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Mes véhicules'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my-vehicles');
                },
              ),
              ListTile(
                leading: const Icon(Icons.request_page),
                title: const Text('Demandes de trajets'),
                onTap: () {
                  Navigator.pop(context);
                  _showRideRequests();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Demandes acceptées'),
                onTap: () {
                  Navigator.pop(context);
                  _showAcceptedRequests();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Groupes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/groups');
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Sécurité'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/security');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Passer en mode Passager'),
                onTap: () {
                  authProvider.switchRole(UserRole.passenger);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorRed),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MyRidesScreen();
      case 2:
        return const MyVehiclesScreen();
      case 3:
        return _buildChatTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 24),
            Text(
              'Actions rapides',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),
            Text(
              'Prochains trajets',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 12),
            _buildUpcomingRides(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${user?.fullName.split(' ')[0] ??
                          "Conducteur"}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Prêt pour un nouveau trajet ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Consumer3<RideProvider, WalletProvider, BookingProvider>(
      builder: (context, rideProvider, walletProvider, bookingProvider, _) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.directions_car,
                label: 'Trajets',
                value: '${rideProvider.myRides.length}',
                color: Colors.blue,
                onTap: () => setState(() => _currentIndex = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                label: 'Passagers',
                value: '${bookingProvider.acceptedRequests.length}',
                color: Colors.green,
                onTap: () => _showAcceptedRequests(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet,
                label: 'Solde',
                value: '${walletProvider.balance.toStringAsFixed(0)} TND',
                color: Colors.orange,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Publier',
            onTap: () => Navigator.pushNamed(context, '/create-ride'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.directions_car_outlined,
            label: 'Véhicules',
            onTap: () => Navigator.pushNamed(context, '/my-vehicles'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_road_outlined,
            label: 'Mes trajets',
            onTap: () => Navigator.pushNamed(context, '/driver-my-rides'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.request_page_outlined,
            label: 'Demandes',
            onTap: () => _showRideRequests(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryBlue),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRides() {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, _) {
        if (rideProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (rideProvider.myRides.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun trajet publié',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/create-ride'),
                    icon: const Icon(Icons.add),
                    label: const Text('Publier un trajet'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: rideProvider.myRides.take(3).map<Widget>((ride) {
            return RideCard(
              ride: ride,
              showDriverInfo: false,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/ride-details',
                  arguments: ride,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRidesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes trajets',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 20),
            Consumer<RideProvider>(
              builder: (context, rideProvider, _) {
                if (rideProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (rideProvider.myRides.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun trajet publié',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Publiez votre premier trajet pour commencer',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/create-ride'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Publier un trajet'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/driver-my-rides'),
                                  icon: const Icon(Icons.list),
                                  label: const Text('Gérer mes trajets'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlue,
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

                return Column(
                  children: [
                    ...rideProvider.myRides.map<Widget>((ride) {
                      return RideCard(
                        ride: ride,
                        showDriverInfo: false,
                        onTap: () {
                          _showRideOptions(ride);
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/driver-my-rides'),
                        icon: const Icon(Icons.list),
                        label: const Text('Gérer tous mes trajets'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demandes de trajets',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.request_page,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gérez les demandes de trajets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Consultez et gérez les demandes de trajets',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ride-requests');
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Ouvrir les demandes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildQuickInfoCard(
                        'Demandes totales',
                        '${bookingProvider.myBookings.length}',
                        Icons.trending_up,
                        AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickInfoCard(
                        'Demandes acceptées',
                        '${bookingProvider.acceptedRequests.length}',
                        Icons.receipt_long,
                        AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard(String label,
      String value,
      IconData icon,
      Color color,) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.chat,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Messagerie',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Communiquez avec les passagers et les conducteurs',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ride-discussions');
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Ouvrir la messagerie'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildQuickChatActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChatActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme
              .of(context)
              .textTheme
              .titleLarge,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.message,
          title: 'Discussions de trajet',
          subtitle: 'Voir toutes les discussions',
          onTap: () => Navigator.pushNamed(context, '/ride-discussions'),
        ),
        _buildActionTile(
          icon: Icons.group,
          title: 'Groupes',
          subtitle: 'Groupes de discussion',
          onTap: () => Navigator.pushNamed(context, '/groups'),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon profil',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final user = authProvider.currentUser;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.primaryBlue.withOpacity(
                                  0.1),
                              child: Text(
                                user?.fullName.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.fullName ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                    Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  user?.rating.toStringAsFixed(1) ?? '0.0',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('Voir mon profil complet'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildQuickActions2(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme
              .of(context)
              .textTheme
              .titleLarge,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.directions_car,
          title: 'Mes véhicules',
          subtitle: 'Gérer mes véhicules',
          onTap: () => Navigator.pushNamed(context, '/my-vehicles'),
        ),
        _buildActionTile(
          icon: Icons.group,
          title: 'Mes groupes',
          subtitle: 'Groupes de covoiturage',
          onTap: () => Navigator.pushNamed(context, '/groups'),
        ),
        _buildActionTile(
          icon: Icons.security,
          title: 'Sécurité',
          subtitle: 'Vérification et sécurité',
          onTap: () => Navigator.pushNamed(context, '/security'),
        ),
        _buildActionTile(
          icon: Icons.settings,
          title: 'Paramètres',
          subtitle: 'Gérer mon compte',
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Mes trajets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Véhicules',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Notifications'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: AppTheme.primaryBlue),
                  title: const Text('Bienvenue sur CarShare!'),
                  subtitle: const Text('Commencez à publier vos trajets'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  void _showRideRequests() {
    Navigator.pushNamed(context, '/ride-requests');
  }

  void _showAcceptedRequests() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            Scaffold(
              appBar: AppBar(title: const Text('Demandes acceptées')),
              body: Consumer<BookingProvider>(
                builder: (context, bookingProvider, _) {
                  if (bookingProvider.acceptedRequests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune demande acceptée',
                            style: TextStyle(fontSize: 18, color: Colors
                                .grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.acceptedRequests.length,
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.acceptedRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue.withOpacity(
                                0.1),
                            child: Text(
                              booking.passengerName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.primaryBlue),
                            ),
                          ),
                          title: Text(booking.passengerName),
                          subtitle: Text(
                              '${booking.seatsBooked} place(s) - ${booking
                                  .totalPrice} TND'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      ),
    );
  }

  void _showRideOptions(ride) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Voir les détails'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/ride-details',
                      arguments: ride,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Modifier'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRideScreen(ride: ride),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _loadData(); // Refresh if ride was updated or deleted
                      }
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                  title: const Text(
                    'Supprimer',
                    style: TextStyle(color: AppTheme.errorRed),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          AlertDialog(
                            title: const Text('Supprimer le trajet'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer ce trajet ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: AppTheme.errorRed),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true && context.mounted) {
                      await context.read<RideProvider>().deleteRide(ride.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Trajet supprimé'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }
}