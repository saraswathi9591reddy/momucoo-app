import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import 'batch1/form_bits.dart';

/// Port of frontend/src/pages/Login.jsx (route /login).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _error = '';
  bool _remember = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Web inputs are `required`; the browser blocks empty submits.
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please fill in your email and password.');
      return;
    }
    final storage = AppStorage.instance;
    final account = storage.account;
    final entered = _email.text.trim().toLowerCase();
    if (account == null || account.email.trim().toLowerCase() != entered || account.password != _password.text) {
      setState(() => _error = 'Account not found or password is incorrect. Please register first.');
      return;
    }
    // Merge name into the stored profile (raw map keeps every existing key, as the web spread does).
    final profile = storage.readMap(StorageKeys.profile) ?? <String, dynamic>{};
    profile['name'] = account.name;
    await storage.writeJson(StorageKeys.profile, profile);
    AppStorage.profileChanged.value++;
    await storage.setLoggedIn(true);
    if (!mounted) return;
    setState(() => _error = '');
    context.go(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const BrandMark(),
            const SizedBox(height: 20),
            const Text('AI-ASSISTED HEALTHCARE',
                style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
            const SizedBox(height: 6),
            Text.rich(
              const TextSpan(children: [
                TextSpan(text: 'Your Health.\n'),
                TextSpan(text: 'Your Care.', style: TextStyle(color: AppColors.primary)),
              ]),
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            const Text('Smart anemia screening, health monitoring and pregnancy screening and care guidance — all in one place.',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            const Wrap(spacing: 8, runSpacing: 8, children: [
              Chip(label: Text('🤖 AI Health Analysis')),
              Chip(label: Text('🤰 Early Pregnancy Care')),
              Chip(label: Text('📈 Health Progress Tracking')),
            ]),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome Back 👋', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text('Sign in to continue your health journey', style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 18),
                      LabeledField(
                        label: 'Email Address',
                        controller: _email,
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      LabeledField(
                        label: 'Password',
                        controller: _password,
                        hint: 'Enter your password',
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        autofillHints: const [AutofillHints.password],
                      ),
                      if (_error.isNotEmpty) AuthError(_error),
                      Row(children: [
                        Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                        const Expanded(child: Text('Remember me')),
                        const Text('Secure login', style: TextStyle(color: AppColors.muted)),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _login, child: const Text('Login as Patient →')),
                      ),
                      const SizedBox(height: 16),
                      const Row(children: [
                        Expanded(child: Divider()),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR')),
                        Expanded(child: Divider()),
                      ]),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(onPressed: () => context.go(Routes.register), child: const Text('Create Account')),
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
