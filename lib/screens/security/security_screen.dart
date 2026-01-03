import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('security')),
      ),
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, _) {
          final user = authProvider.currentUser;
          final userState = userProvider.currentUser ?? user;

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
                            ? t.t('profile_verified')
                            : t.t('profile_not_verified'),
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
                t.t('verification_status'),
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
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Column(
                    children: [
                      _buildVerificationItem(
                        icon: Icons.badge,
                        title: t.t('upload_id'),
                        isVerified: userState?.idDocumentUrl != null,
                        isProcessing: userProvider.isUploading,
                        onTap: () async {
                          // Pick file and upload ID
                          final result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result == null || result.files.isEmpty) return;
                          final path = result.files.first.path;
                          if (path == null) return;

                          final file = File(path);
                          await userProvider.uploadIdDocument(file);

                          final updatedUrl = userProvider.currentUser?.idDocumentUrl;
                          if (updatedUrl != null && user != null) {
                            final next = user.copyWith(idDocumentUrl: updatedUrl, updatedAt: DateTime.now());
                            // auto verify if both docs exist
                            final hasLicense = userProvider.currentUser?.licenseDocumentUrl != null;
                            final withVerify = hasLicense ? next.copyWith(isVerified: true) : next;
                            authProvider.updateUser(withVerify);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('id_uploaded'))));
                        },
                      ),
                      _buildVerificationItem(
                        icon: Icons.directions_car,
                        title: t.t('upload_license'),
                        isVerified: userState?.licenseDocumentUrl != null,
                        isProcessing: userProvider.isUploading,
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result == null || result.files.isEmpty) return;
                          final path = result.files.first.path;
                          if (path == null) return;

                          final file = File(path);
                          await userProvider.uploadLicenseDocument(file);

                          final updatedUrl = userProvider.currentUser?.licenseDocumentUrl;
                          if (updatedUrl != null && user != null) {
                            final next = user.copyWith(licenseDocumentUrl: updatedUrl, updatedAt: DateTime.now());
                            final hasId = userProvider.currentUser?.idDocumentUrl != null;
                            final withVerify = hasId ? next.copyWith(isVerified: true) : next;
                            authProvider.updateUser(withVerify);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('license_uploaded'))));
                        },
                      ),
                    ],
                  );
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
                  Navigator.pushNamed(context, AppRoutes.reviews);
                },
              ),
              _buildSecurityItem(
                icon: Icons.warning,
                title: t.t('report_issue'),
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
                  Navigator.pushNamed(context, AppRoutes.help);
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
                            Text(
                              t.t('emergency_contact'),
                              style: const TextStyle(
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
                          _callEmergency(context);
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
    bool isProcessing = false,
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
            : (isProcessing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton(
                    onPressed: onTap,
                    child: const Text('Vérifier'),
                  )),
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
    final t = AppLocalizations.of(context);
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
            Text(
              'Présentez ce code au conducteur pour vérifier votre identité',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('close')),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('report_issue')),
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
            child: Text(t.t('cancel')),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergency(BuildContext context) async {
    final Uri tel = Uri(scheme: 'tel', path: '197');
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'appeler le numéro d\'urgence')));
    }
  }
}
