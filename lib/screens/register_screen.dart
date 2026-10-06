import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import 'batch1/form_bits.dart';

/// Port of frontend/src/pages/Register.jsx (route /register).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _error = '';

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    final email = _email.text.trim().toLowerCase();
    if (name.isEmpty || email.isEmpty || _password.text.length < 6) {
      setState(() => _error = 'Enter your name, a valid email, and a password of at least 6 characters.');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    final storage = AppStorage.instance;
    await storage.saveAccount(Account(name: name, email: email, password: _password.text));
    await storage.saveProfile(Profile(name: name, pregnancyStatus: 'Pregnant'));
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandMark(),
                      const SizedBox(height: 14),
                      Text('Create Your Account', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text('Start your early-pregnancy health journey with Momucoo', style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.peachBg,
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('👤 Patient account',
                            textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                      const SizedBox(height: 16),
                      LabeledField(label: 'Full Name', controller: _name, hint: 'Enter your name',
                          keyboardType: TextInputType.name, autofillHints: const [AutofillHints.name]),
                      LabeledField(label: 'Email', controller: _email, hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
                      LabeledField(label: 'Password', controller: _password, hint: 'Create password', obscure: true,
                          autofillHints: const [AutofillHints.newPassword]),
                      LabeledField(label: 'Confirm Password', controller: _confirm, hint: 'Confirm password', obscure: true,
                          textInputAction: TextInputAction.done, onSubmitted: (_) => _register()),
                      if (_error.isNotEmpty) AuthError(_error),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _register, child: const Text('Create Account →')),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(onPressed: () => context.go(Routes.login), child: const Text('Login')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
