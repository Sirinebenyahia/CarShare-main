import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centre d\'aide')), 
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Centre d\'aide & sécurité', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Comment vérifier un conducteur ou passager'),
          SizedBox(height: 8),
          Text('• Mes conseils pour voyager en toute sécurité'),
          SizedBox(height: 8),
          Text('• Signaler un problème ou un abus'),
          SizedBox(height: 8),
          Text('Pour plus d\'informations, contactez notre support via l\'application.'),
        ],
      ),
    );
  }
}
