import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../services/ride_service.dart';
import '../widgets/back_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _loading = false;
  String? _error;
  bool _isRegister = false;
  String _userType = 'passenger';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  Future<void> _continue(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = AuthService();
      final rideService = RideService();

      if (_isRegister) {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw Exception('Les mots de passe ne correspondent pas.');
        }
        if (_passwordController.text.length < 6) {
          throw Exception('Le mot de passe doit contenir au moins 6 caracteres.');
        }
        if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
          throw Exception('Le nom et prénom sont obligatoires.');
        }
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final cred = _isRegister
          ? await auth.signUpWithEmail(email: email, password: password)
          : await auth.signInWithEmail(email: email, password: password);

      // Créer le profil utilisateur après inscription
      if (_isRegister) {
        final profileData = {
          'email': email,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'userType': _userType,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set(profileData);
      }

      await rideService.ensureUserDoc(user: cred.user!);
      await rideService.seedSampleRideIfEmpty(user: cred.user!);

      if (!context.mounted) return;
      
      // Rediriger vers l'ecran de completion de profil si nouvel utilisateur
      if (_isRegister) {
        Navigator.of(context).pushReplacementNamed('/profile_setup');
      } else {
        context.go('/verification');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _friendlyAuthError(e);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithBack(
        title: '',
        fallbackRoute: '/home',
        customOnBackPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_car, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bienvenue sur CarShare Tunisie',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connectez-vous ou creez un compte pour commencer votre voyage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _loading ? null : () {
                              setState(() {
                                _isRegister = false;
                                _error = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isRegister ? const Color(0xFF2563EB) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!_isRegister) ...[
                                    const Icon(Icons.check, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    'Connexion',
                                    style: TextStyle(
                                      color: !_isRegister ? Colors.white : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _loading ? null : () {
                              setState(() {
                                _isRegister = true;
                                _error = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isRegister ? const Color(0xFF2563EB) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isRegister) ...[
                                    const Icon(Icons.check, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    'Inscription',
                                    style: TextStyle(
                                      color: _isRegister ? Colors.white : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Type d'utilisateur (pour inscription)
                    if (_isRegister) ...[
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

                      // Champs additionnels pour inscription
                      if (_isRegister) ...[
                        _buildTextField(_firstNameController, 'Prénom', TextInputType.name),
                        const SizedBox(height: 15),
                        _buildTextField(_lastNameController, 'Nom', TextInputType.name),
                        const SizedBox(height: 15),
                        _buildTextField(_phoneController, 'Numéro de téléphone', TextInputType.phone),
                        const SizedBox(height: 20),
                      ],
                    ],

                    _buildTextField(_emailController, 'Adresse email', TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Mot de passe', TextInputType.text, obscureText: true),
                    if (_isRegister) ...[
                      const SizedBox(height: 16),
                      _buildTextField(_confirmPasswordController, 'Confirmer le mot de passe', TextInputType.text, obscureText: true),
                    ],
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => _continue(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _loading
                              ? 'Chargement...'
                              : (_isRegister ? 'Creer un compte' : 'Se connecter'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est deja utilise. Essayez Connexion.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caracteres).';
      case 'user-not-found':
        return 'Aucun compte trouve avec cet email. Essayez Inscription.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'operation-not-allowed':
        return "Methode Email/Mot de passe desactivee dans Firebase Console > Authentication > Sign-in method.";
      case 'network-request-failed':
        return 'Probleme reseau. Verifie ta connexion Internet.';
      case 'too-many-requests':
        return 'Trop de tentatives. Reessaie plus tard.';
      default:
        return e.message ?? 'Erreur Auth: ${e.code}';
    }
  }
}
