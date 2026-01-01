import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité & Vérification'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Verification Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: user?.isVerified == true
                              ? AppTheme.successGreen.withOpacity(0.1)
                              : AppTheme.warningOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          user?.isVerified == true
                              ? Icons.verified_user
                              : Icons.shield_outlined,
                          size: 40,
                          color: user?.isVerified == true
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.isVerified == true
                            ? 'Profil Vérifié'
                            : 'Profil Non Vérifié',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: user?.isVerified == true
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.isVerified == true
                            ? 'Votre identité a été vérifiée'
                            : 'Vérifiez votre identité pour plus de sécurité',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (user?.isVerified == false) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to verification process
                            },
                            icon: const Icon(Icons.verified_user),
                            label: const Text('Vérifier mon profil'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Verification Items
              Text(
                'Éléments de vérification',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              _buildVerificationItem(
                icon: Icons.email,
                title: 'Email vérifié',
                isVerified: true,
                onTap: () {},
              ),
              _buildVerificationItem(
                icon: Icons.phone,
                title: 'Téléphone vérifié',
                isVerified: user?.phoneNumber != null,
                onTap: () {
                  // TODO: Verify phone
                },
              ),
              _buildVerificationItem(
                icon: Icons.badge,
                title: 'Pièce d\'identité',
                isVerified: user?.isVerified == true,
                onTap: () {
                  // TODO: Upload ID
                },
              ),
              _buildVerificationItem(
                icon: Icons.directions_car,
                title: 'Permis de conduire',
                isVerified: false,
                onTap: () {
                  // TODO: Upload license
                },
              ),

              const SizedBox(height: 24),

              // Security Features
              Text(
                'Fonctionnalités de sécurité',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              _buildSecurityItem(
                icon: Icons.qr_code,
                title: 'Code QR de vérification',
                subtitle: 'Générer un code QR pour vérifier votre trajet',
                onTap: () {
                  _showQRCodeDialog(context);
                },
              ),
              _buildSecurityItem(
                icon: Icons.star,
                title: 'Avis et évaluations',
                subtitle: 'Voir les avis des autres utilisateurs',
                onTap: () {
                  // TODO: Navigate to reviews
                },
              ),
              _buildSecurityItem(
                icon: Icons.warning,
                title: 'Signaler un problème',
                subtitle: 'Signaler un comportement inapproprié',
                onTap: () {
                  _showReportDialog(context);
                },
              ),
              _buildSecurityItem(
                icon: Icons.help,
                title: 'Centre d\'aide sécurité',
                subtitle: 'Conseils pour voyager en toute sécurité',
                onTap: () {
                  // TODO: Navigate to help center
                },
              ),

              const SizedBox(height: 24),

              // Emergency Contact
              Card(
                color: AppTheme.errorRed.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: AppTheme.errorRed,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact d\'urgence',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'En cas d\'urgence, appelez le 197',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Call emergency
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVerificationItem({
    required IconData icon,
    required String title,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isVerified
                ? AppTheme.successGreen.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isVerified ? AppTheme.successGreen : AppTheme.greyText,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: isVerified
            ? const Icon(Icons.check_circle, color: AppTheme.successGreen)
            : TextButton(
                onPressed: onTap,
                child: const Text('Vérifier'),
              ),
      ),
    );
  }

  Widget _buildSecurityItem({
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
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code QR de vérification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 150,
                  color: AppTheme.greyText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Présentez ce code au conducteur pour vérifier votre identité',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Que souhaitez-vous signaler ?'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Comportement inapproprié'),
              leading: const Icon(Icons.warning),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report inappropriate behavior
              },
            ),
            ListTile(
              title: const Text('Problème de sécurité'),
              leading: const Icon(Icons.security),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report security issue
              },
            ),
            ListTile(
              title: const Text('Autre'),
              leading: const Icon(Icons.help_outline),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report other issue
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
