import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: user.profileImageUrl != null
                                ? null
                                : Text(
                                    user.fullName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                          ),
                          if (user.isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.successGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            user.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Trajets',
                          '${user.totalRides}',
                          Icons.directions_car,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Note',
                          user.rating.toStringAsFixed(1),
                          Icons.star,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Membre depuis',
                          _getYearsSince(user.createdAt),
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Info Section
                _buildInfoSection(
                  'Informations personnelles',
                  [
                    _buildInfoTile(
                      Icons.phone,
                      'Téléphone',
                      user.phoneNumber ?? 'Non renseigné',
                    ),
                    _buildInfoTile(
                      Icons.location_city,
                      'Ville',
                      user.city ?? 'Non renseignée',
                    ),
                    _buildInfoTile(
                      Icons.cake,
                      'Date de naissance',
                      user.dateOfBirth != null
                          ? '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                          : 'Non renseignée',
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty)
                      _buildInfoTile(
                        Icons.info_outline,
                        'Bio',
                        user.bio!,
                      ),
                  ],
                ),

                const Divider(height: 1),

                // Verification Section
                _buildInfoSection(
                  'Vérification',
                  [
                    ListTile(
                      leading: Icon(
                        user.isVerified ? Icons.verified : Icons.cancel,
                        color: user.isVerified
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                      ),
                      title: Text(
                        user.isVerified
                            ? 'Profil vérifié'
                            : 'Profil non vérifié',
                      ),
                      trailing: user.isVerified
                          ? null
                          : TextButton(
                              onPressed: () {
                                // TODO: Navigate to verification
                              },
                              child: const Text('Vérifier'),
                            ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Modifier le profil',
                        icon: Icons.edit,
                        isOutlined: true,
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-profile');
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Voir mes avis',
                        icon: Icons.rate_review,
                        isOutlined: true,
                        onPressed: () {
                          // TODO: Navigate to reviews
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
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

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.greyText),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  String _getYearsSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final years = difference.inDays ~/ 365;
    
    if (years == 0) {
      final months = difference.inDays ~/ 30;
      return '${months}m';
    }
    return '${years}a';
  }
}
