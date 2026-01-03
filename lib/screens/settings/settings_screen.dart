import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('settings_title')),
      ),
      body: Builder(
        builder: (context) {
          final langLabel = context.watch<LocaleProvider>().languageLabel;
          return ListView(
        children: [
          // Account Section
          _buildSectionHeader(t.t('account')),
          _buildSettingTile(
            icon: Icons.person,
            title: t.t('edit_profile'),
            subtitle: t.t('edit_profile_subtitle'),
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          _buildSettingTile(
            icon: Icons.lock,
            title: t.t('change_password'),
            subtitle: t.t('change_password_subtitle'),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          _buildSettingTile(
            icon: Icons.verified_user,
            title: t.t('account_verification'),
            subtitle: t.t('account_verification_subtitle'),
            onTap: () {
              Navigator.pushNamed(context, '/security');
            },
          ),

          const Divider(height: 32),

          // Notifications Section
          _buildSectionHeader(t.t('notifications')),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: t.t('push_notifications'),
            subtitle: t.t('push_notifications_subtitle'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.email,
            title: t.t('email_notifications'),
            subtitle: t.t('email_notifications_subtitle'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.sms,
            title: t.t('sms_notifications'),
            subtitle: t.t('sms_notifications_subtitle'),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() => _smsNotifications = value);
            },
          ),

          const Divider(height: 32),

          // Sound & Vibration
          _buildSectionHeader(t.t('sounds_and_vibrations')),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: t.t('sounds'),
            subtitle: t.t('sounds_subtitle'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: t.t('vibrations'),
            subtitle: t.t('vibrations_subtitle'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
            },
          ),

          const Divider(height: 32),

          // Privacy Section
          _buildSectionHeader(t.t('privacy_security')),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: t.t('privacy_policy'),
            subtitle: t.t('privacy_policy_subtitle'),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          _buildSettingTile(
            icon: Icons.description,
            title: t.t('terms'),
            subtitle: t.t('terms_subtitle'),
            onTap: () {
              // TODO: Show terms
            },
          ),
          _buildSettingTile(
            icon: Icons.block,
            title: t.t('blocked_users'),
            subtitle: t.t('blocked_users_subtitle'),
            onTap: () {
              // TODO: Show blocked users
            },
          ),

          const Divider(height: 32),

          // App Section
          _buildSectionHeader(t.t('application')),
          _buildSettingTile(
            icon: Icons.language,
            title: t.t('language'),
            subtitle: langLabel,
            onTap: () {
              _showLanguageDialog();
            },
          ),
          _buildSettingTile(
            icon: Icons.info,
            title: t.t('about'),
            subtitle: t.t('about_subtitle'),
            onTap: () {
              _showAboutDialog();
            },
          ),
          _buildSettingTile(
            icon: Icons.help,
            title: t.t('help_support'),
            subtitle: t.t('help_support_subtitle'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.help);
            },
          ),

          const Divider(height: 32),

          // Danger Zone
          _buildSectionHeader(t.t('danger_zone')),
          _buildSettingTile(
            icon: Icons.logout,
            iconColor: AppTheme.errorRed,
            title: t.t('logout'),
            titleColor: AppTheme.errorRed,
            subtitle: t.t('logout_subtitle'),
            onTap: () {
              _showLogoutDialog();
            },
          ),
          _buildSettingTile(
            icon: Icons.delete_forever,
            iconColor: AppTheme.errorRed,
            title: t.t('delete_account'),
            titleColor: AppTheme.errorRed,
            subtitle: t.t('delete_account_subtitle'),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),

          const SizedBox(height: 32),
        ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryBlue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final t = AppLocalizations.of(context);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('change_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: t.t('current_password')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: t.t('new_password')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: t.t('confirm_password')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              // TODO: Change password
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.t('password_changed_success')),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: Text(t.t('change')),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('choose_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: const Icon(Icons.check, color: AppTheme.primaryBlue),
              onTap: () async {
                await context.read<LocaleProvider>().setLocale(const Locale('fr'), 'Français');
                await initializeDateFormatting('fr_FR', null);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('language_changed_fr'))));
                // Force rebuild of the entire app
                LocaleProvider.rebuildApp(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () async {
                await context.read<LocaleProvider>().setLocale(const Locale('ar'), 'العربية');
                await initializeDateFormatting('ar', null);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('language_changed_ar'))));
                // Force rebuild of the entire app
                LocaleProvider.rebuildApp(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () async {
                await context.read<LocaleProvider>().setLocale(const Locale('en'), 'English');
                await initializeDateFormatting('en_US', null);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.t('language_changed_en'))));
                // Force rebuild of the entire app
                LocaleProvider.rebuildApp(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('about')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              t.t('about_app_name'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(t.t('about_version')),
            const SizedBox(height: 16),
            Text(
              t.t('about_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
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

  void _showLogoutDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('disconnect_confirm_title')),
        content: Text(t.t('disconnect_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: Text(
              t.t('disconnect'),
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.t('delete_account_title')),
        content: Text(t.t('delete_account_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<AuthProvider>().deleteAccount();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${t.t('error')}: ${e.toString()}'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            child: Text(
              t.t('delete'),
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
