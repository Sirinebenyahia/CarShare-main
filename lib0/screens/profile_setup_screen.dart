import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import '../widgets/back_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _plateController = TextEditingController();
  final _experienceController = TextEditingController(text: '0');
  
  String _userType = 'passenger';
  bool _isLoading = false;
  String? _profileImageUrl;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _plateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() => _isLoading = true);
        
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
            
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        
        setState(() {
          _profileImageUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du téléchargement de la photo';
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value!.trim().isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      
      final profileData = {
        'email': user.email!,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'userType': _userType,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // Ajouter la photo de profil si disponible
      if (_profileImageUrl != null) {
        profileData['profileImageUrl'] = _profileImageUrl!;
      }

      // Ajouter les champs spécifiques au conducteur
      if (_userType == 'driver') {
        profileData['driverLicense'] = _licenseController.text.trim();
        profileData['carModel'] = _carModelController.text.trim();
        profileData['carColor'] = _carColorController.text.trim();
        profileData['carPlateNumber'] = _plateController.text.trim();
        profileData['yearOfExperience'] = int.tryParse(_experienceController.text) ?? 0;
        profileData['isVerifiedDriver'] = false;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profileData);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la sauvegarde du profil';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithBack(
        title: 'Compléter votre profil',
        fallbackRoute: '/home',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Photo de profil
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImageUrl != null 
                        ? NetworkImage(_profileImageUrl!) 
                        : null,
                    child: _profileImageUrl == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ajouter une photo',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Type d'utilisateur
                const Text('Type de compte', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Passager'),
                        value: 'passenger',
                        groupValue: _userType,
                        onChanged: (value) => setState(() => _userType = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Conducteur'),
                        value: 'driver',
                        groupValue: _userType,
                        onChanged: (value) => setState(() => _userType = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Champs de base
                _buildTextField(_firstNameController, 'Prénom', TextInputType.name),
                const SizedBox(height: 15),
                _buildTextField(_lastNameController, 'Nom', TextInputType.name),
                const SizedBox(height: 15),
                _buildTextField(_phoneController, 'Numéro de téléphone', TextInputType.phone),
                const SizedBox(height: 20),

                // Champs spécifiques au conducteur
                if (_userType == 'driver') ...[
                  const Text('Informations du véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildTextField(_licenseController, 'Numéro de permis', TextInputType.text),
                  const SizedBox(height: 15),
                  _buildTextField(_carModelController, 'Modèle du véhicule', TextInputType.text),
                  const SizedBox(height: 15),
                  _buildTextField(_carColorController, 'Couleur du véhicule', TextInputType.text),
                  const SizedBox(height: 15),
                  _buildTextField(_plateController, 'Immatriculation', TextInputType.text),
                  const SizedBox(height: 15),
                  _buildTextField(_experienceController, 'Années d\'expérience', TextInputType.number),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 30),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 15),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sauvegarder le profil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
