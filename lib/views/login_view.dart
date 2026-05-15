
// Authentication screen - the single entry point for both students
//          and admins (Assignment: "single authentication mechanism for all
//          users"). After successful sign-in, AuthWrapper routes the user to      
//the correct portal based on role.


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../routes/route_manager.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/ui_kit.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Form key for validation (Unit 4 - GlobalKey<FormState>)
  final _formKey = GlobalKey<FormState>();

  // Controllers - created in initState, disposed in dispose (Unit 4 lifecycle)
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;

  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Sign-in handler. Validates the form (Unit 4), then calls the
  /// AuthViewModel (Unit 5).
  Future<void> _submit() async {
    // 1. Validate all fields at once (Unit 4)
    if (!_formKey.currentState!.validate()) return;

    // 2. Send to ViewModel via context.read (Unit 2 - read for actions)
    final ok = await context
        .read<AuthViewModel>()
        .signIn(_emailCtrl.text, _passwordCtrl.text);

    if (!mounted) return;

    if (ok) {
      // AuthWrapper will pick the right screen, so we just reset the stack.
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteManager.wrapper,
        (_) => false,
      );
    } else {
      final msg = context.read<AuthViewModel>().errorMessage ?? 'Sign-in failed';
      _showError(msg);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.rejected,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel for isLoading rebuilds (Unit 2 - watch for data)
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 64,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============= HEADER STRIP =============
                  // Mono-tagged identifier that frames the screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TPG316C / 2026', style: AppTheme.label),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // ============= BIG SERIF DISPLAY =============
                  // The aesthetic anchor of the whole app
                  Text('Student', style: AppTheme.displayLg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Assistant',
                          style: AppTheme.displayLg.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.accent,
                          )),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          width: 8,
                          height: 8,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Application System  —  Department of Information Technology',
                    style: AppTheme.bodyMuted.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 48),

                  // ============= SIGN-IN SECTION =============
                  const SectionLabel('Sign In', index: '01'),
                  const SizedBox(height: 20),

                  // ============= FORM =============
                  // Unit 4: Form + GlobalKey<FormState> + TextFormField
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // EMAIL FIELD
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: AppTheme.body,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            hintText: 'student@cut.ac.za',
                          ),
                          // Field-level validator (Unit 4)
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            // Regex check (Unit 4 - validation patterns)
                            final emailRegex =
                                RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // PASSWORD FIELD
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          style: AppTheme.body,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Minimum 6 characters',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textMid,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        PrimaryButton(
                          label: 'Sign In',
                          icon: Icons.arrow_forward,
                          isLoading: auth.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),

                        // Link to sign-up
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, RouteManager.signup),
                            child: RichText(
                              text: TextSpan(
                                style: AppTheme.bodyMuted,
                                children: const [
                                  TextSpan(text: 'No account yet?  '),
                                  TextSpan(
                                    text: 'Register',
                                    style: TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ============= FOOTER =============
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('INFORMATION SECURED', style: AppTheme.label),
                      Text('GROUP_Y', style: AppTheme.label),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}