import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
      _cityController.text = user.city ?? '';
      _bioController.text = user.bio ?? '';
      _dateOfBirth = user.dateOfBirth;
      _imagePath = user.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      setState(() => _imagePath = picked.path);

      // Upload immediately to Firebase Storage via UserProvider
      try {
        final file = File(picked.path);
        await context.read<UserProvider>().uploadProfileImage(file);
        final updatedUrl = context.read<UserProvider>().currentUser?.profileImageUrl;
        if (updatedUrl != null) {
          setState(() => _imagePath = updatedUrl);
          final auth = context.read<AuthProvider>();
          final current = auth.currentUser;
          if (current != null) {
            auth.updateUser(current.copyWith(profileImageUrl: updatedUrl, updatedAt: DateTime.now()));
          }
        }
      } catch (e) {
        // ignore for now
      }
    }
  }

  Future<void> _removeImage() async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('delete_profile_photo_title')),
        content: Text(t.t('delete_profile_photo_body')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.t('cancel'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.t('delete'))),
        ],
      ),
    );

    if (confirm == true) {
      // Update auth provider user
      final auth = context.read<AuthProvider>();
      final current = auth.currentUser;
      if (current != null) {
        final updated = current.copyWith(profileImageUrl: null, updatedAt: DateTime.now());
        auth.updateUser(updated);
      }
      // keep local state in sync
      setState(() => _imagePath = null);
      // Also call UserProvider if desired
      await context.read<UserProvider>().deleteProfileImage();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    final current = auth.currentUser;
    if (current == null) return;

    final updated = current.copyWith(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      dateOfBirth: _dateOfBirth,
      profileImageUrl: _imagePath,
      updatedAt: DateTime.now(),
    );

    // Update providers (mocked/local)
    auth.updateUser(updated);
    await context.read<UserProvider>().updateProfile(
          fullName: updated.fullName,
          phoneNumber: updated.phoneNumber,
          city: updated.city,
          bio: updated.bio,
          dateOfBirth: updated.dateOfBirth,
        );

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('edit_profile_title')),
        actions: [
          TextButton(
            key: const Key('edit_save_button'),
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(t.t('save'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _imagePath != null
                              ? (_imagePath!.startsWith('http') ? NetworkImage(_imagePath!) : FileImage(File(_imagePath!)) as ImageProvider)
                              : null,
                          child: _imagePath == null
                              ? Text(
                                  context.read<AuthProvider>().currentUser!.fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              if (userProvider.isUploading) const Padding(
                                padding: EdgeInsets.only(right:8.0),
                                child: SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2)),
                              ),
                              IconButton(key: const Key('edit_pick_image_button'), onPressed: _pickImage, icon: const Icon(Icons.photo_camera)),
                              IconButton(key: const Key('edit_remove_image_button'), onPressed: _removeImage, icon: const Icon(Icons.delete_outline)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: t.t('full_name')),
                  validator: (v) => v == null || v.trim().length < 2 ? t.t('enter_valid_name') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: t.t('phone')),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: t.t('city')),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: t.t('bio')),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : t.t('date_of_birth'),
                      ),
                    ),
                    TextButton(onPressed: _pickDate, child: Text(t.t('choose'))),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(t.t('save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
