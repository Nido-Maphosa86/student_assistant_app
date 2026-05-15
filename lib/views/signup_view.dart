/*
Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng
 Purpose: Account registration (Unit 5 Supabase signUp). New accounts
          default to the "student" role.
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../widgets/ui_kit.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _confirmCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context
        .read<AuthViewModel>()
        .signUp(_emailCtrl.text, _passwordCtrl.text);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Account created. Please sign in.',
            style: TextStyle(color: AppTheme.canvas),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      final msg = context.read<AuthViewModel>().errorMessage ?? 'Sign-up failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.rejected,
          behavior: SnackBarBehavior.floating,
          content: Text(msg, style: const TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('REGISTER', style: AppTheme.label),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Create', style: AppTheme.displayMd),
              Text(
                'Account',
                style: AppTheme.displayMd.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Registers a new student account. Apply for one Student '
                'Assistant position after signing in.',
                style: AppTheme.bodyMuted.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 32),
              const SectionLabel('Credentials', index: '01'),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: AppTheme.body,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                            .hasMatch(v.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      style: AppTheme.body,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      style: AppTheme.body,
                      decoration:
                          const InputDecoration(labelText: 'Confirm password'),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Create account',
                      icon: Icons.person_add_outlined,
                      isLoading: auth.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



