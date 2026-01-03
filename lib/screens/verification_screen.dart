import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/ride_service.dart';
import '../services/storage_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _cin = TextEditingController();
  PlatformFile? picked;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    _cin.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (res == null || res.files.isEmpty) return;
    setState(() {
      picked = res.files.first;
      error = null;
    });
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/welcome');
      return;
    }
    if (picked?.bytes == null) {
      setState(() => error = 'Veuillez choisir un fichier.');
      return;
    }
    if (_cin.text.trim().isEmpty) {
      setState(() => error = 'Veuillez entrer votre numéro CIN.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final file = picked!;
      final name = file.name;
      final bytes = file.bytes!;
      final ext = name.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'pdf' => 'application/pdf',
        _ => 'application/octet-stream',
      };

      final url = await StorageService().uploadUserCin(
        uid: user.uid,
        fileName: name,
        bytes: bytes,
        contentType: contentType,
      );

      await RideService().updateUserCin(
        uid: user.uid,
        cinNumber: _cin.text.trim(),
        cinFileUrl: url,
      );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification CIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Téléchargez une copie de votre carte d\'identité nationale pour vérification.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cin,
                decoration: InputDecoration(
                  labelText: 'Numéro CIN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: loading ? null : _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    picked == null
                        ? 'Télécharger document CIN (JPG/PNG/PDF)'
                        : 'Fichier: ${picked!.name}',
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              const Spacer(),
              FilledButton(
                onPressed: loading ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(loading ? 'Envoi...' : 'Soumettre pour vérification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
