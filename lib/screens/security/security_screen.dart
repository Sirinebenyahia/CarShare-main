import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
                              _startVerificationProcess(context);
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
                  _showPhoneVerificationDialog(context);
                },
              ),
              _buildVerificationItem(
                icon: Icons.badge,
                title: 'Pièce d\'identité',
                isVerified: user?.isVerified == true,
                onTap: () {
                  _uploadIDDocument(context);
                },
              ),
              _buildVerificationItem(
                icon: Icons.directions_car,
                title: 'Permis de conduire',
                isVerified: false,
                onTap: () {
                  _uploadLicenseDocument(context);
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
                  _showReviewsScreen(context);
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
                  _showSecurityHelp(context);
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
                          _makeEmergencyCall();
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
                _showReportDetails(context, 'Comportement inapproprié');
              },
            ),
            ListTile(
              title: const Text('Problème de sécurité'),
              leading: const Icon(Icons.security),
              onTap: () {
                Navigator.pop(context);
                _showReportDetails(context, 'Problème de sécurité');
              },
            ),
            ListTile(
              title: const Text('Autre'),
              leading: const Icon(Icons.help_outline),
              onTap: () {
                Navigator.pop(context);
                _showReportDetails(context, 'Autre');
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

  void _startVerificationProcess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Processus de vérification'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pour vérifier votre profil, vous devrez :'),
            SizedBox(height: 12),
            Text('• Télécharger votre pièce d\'identité'),
            Text('• Télécharger votre permis de conduire'),
            Text('• Vérifier votre numéro de téléphone'),
            SizedBox(height: 12),
            Text('Ce processus peut prendre 24-48h.', 
                 style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadIDDocument(context);
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  void _showPhoneVerificationDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérifier le téléphone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre numéro de téléphone :'),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+216 XX XXX XXX',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code de vérification envoyé !'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Envoyer le code'),
          ),
        ],
      ),
    );
  }

  void _uploadIDDocument(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Télécharger la pièce d\'identité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez comment vous voulez télécharger votre CIN :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera, 'CIN');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery, 'CIN');
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

  void _uploadLicenseDocument(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Télécharger le permis de conduire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez comment vous voulez télécharger votre permis :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera, 'Permis');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery, 'Permis');
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

  void _pickImage(BuildContext context, ImageSource source, String documentType) {
    ImagePicker().pickImage(source: source).then((image) {
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$documentType téléchargé avec succès !'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    });
  }

  void _showReviewsScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avis et évaluations'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildReviewItem('Mohamed Ali', 5, 'Excellent conducteur, très ponctuel !'),
                    _buildReviewItem('Sarra Ben', 4, 'Bon trajet, voiture propre'),
                    _buildReviewItem('Youssef', 5, 'Super expérience, recommande !'),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildReviewItem(String name, int rating, String comment) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(comment),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) => 
          Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
          ),
        ),
      ),
    );
  }

  void _showSecurityHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conseils de sécurité'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Vérifiez toujours le profil du conducteur/passager', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Partagez vos informations de trajet avec un proche'),
              SizedBox(height: 8),
              Text('• Rencontrez-vous dans des lieux publics'),
              SizedBox(height: 8),
              Text('• Faites confiance à votre instinct'),
              SizedBox(height: 8),
              Text('• Signalez tout comportement suspect'),
              SizedBox(height: 8),
              Text('• Gardez votre téléphone chargé'),
              SizedBox(height: 8),
              Text('• Utilisez le code QR de vérification'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _makeEmergencyCall() async {
    final Uri emergencyUri = Uri(scheme: 'tel', path: '197');
    try {
      await launchUrl(emergencyUri);
    } catch (e) {
      debugPrint('Could not launch emergency call: $e');
    }
  }

  void _showReportDetails(BuildContext context, String reportType) {
    final TextEditingController detailsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Signaler : $reportType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Décrivez le problème ($reportType) :'),
            const SizedBox(height: 12),
            TextField(
              controller: detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez ce qui s\'est passé...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signalement envoyé. Nous allons traiter votre demande.'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
