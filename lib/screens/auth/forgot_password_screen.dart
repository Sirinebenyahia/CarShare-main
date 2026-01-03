import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().forgotPassword(
        email: _emailController.text.trim(),
      );

      setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.t('error')}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(t.t('forgot_password_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    final t = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            t.t('reset_password_title'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            t.t('reset_password_desc'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.greyText,
            ),
          ),
          const SizedBox(height: 32),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: t.t('email'),
            hint: t.t('email_hint'),
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return t.t('enter_email');
              }
              if (!value.contains('@')) {
                return t.t('invalid_email');
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          CustomButton(
            text: t.t('send_link'),
            isLoading: _isLoading,
            onPressed: _handleForgotPassword,
          ),
          const SizedBox(height: 16),

          // Back to Login
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.t('back_to_login')),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),

        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: AppTheme.successGreen,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          t.t('email_sent_title'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          '${t.t('email_sent_desc_prefix')}${_emailController.text}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.greyText,
          ),
        ),
        const SizedBox(height: 48),

        // Back to Login Button
        CustomButton(
          text: t.t('back_to_login'),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),

        // Resend Link
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(t.t('resend_link')),
        ),
      ],
    );
  }
}
