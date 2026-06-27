import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_text_field.dart';
import '../../widgets/supa_button.dart';
enum AuthMode { login, signup, forgot, verify }

class FirebaseAuthScreen extends StatefulWidget {
  const FirebaseAuthScreen({super.key});

  @override
  State<FirebaseAuthScreen> createState() => _FirebaseAuthScreenState();
}

class _FirebaseAuthScreenState extends State<FirebaseAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  AuthMode _mode = AuthMode.login;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }

    if (_mode != AuthMode.forgot && password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_mode == AuthMode.login) {
        final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        if (!userCred.user!.emailVerified) {
          setState(() {
            _mode = AuthMode.verify;
            _isLoading = false;
          });
          return;
        }
        if (mounted) Navigator.of(context).pop();
      } else if (_mode == AuthMode.signup) {
        final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await userCred.user!.sendEmailVerification();
        setState(() {
          _mode = AuthMode.verify;
          _isLoading = false;
        });
      } else if (_mode == AuthMode.forgot) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        setState(() {
          _successMessage = 'Password reset link sent to your email.';
          _mode = AuthMode.login;
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Authentication failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      setState(() {
        _successMessage = 'Verification email resent.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == AuthMode.verify) {
      return Scaffold(
        backgroundColor: AppColors.bgBase,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.white)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_rounded, size: 64, color: AppColors.supaGreen),
                const SizedBox(height: 24),
                Text('Verify your email', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('We sent a verification link to\n${_emailController.text}\n\nPlease click it to continue.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_successMessage!, style: const TextStyle(color: AppColors.supaGreen, fontSize: 14)),
                ],
                const SizedBox(height: 32),
                SupaButton(text: 'Resend Email', onPressed: _resendVerification),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    setState(() => _mode = AuthMode.login);
                  },
                  child: Text('Back to Sign In', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _mode == AuthMode.forgot ? Icons.email_outlined : Icons.lock_outline_rounded, 
                  size: 48, 
                  color: AppColors.supaGreen
                ),
                const SizedBox(height: 24),
                Text(
                  _mode == AuthMode.login ? 'Sign In' : _mode == AuthMode.signup ? 'Create Account' : 'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  _mode == AuthMode.login 
                    ? 'Welcome back to SupaMobile.'
                    : _mode == AuthMode.signup 
                      ? 'Start managing your databases on the go.'
                      : 'Enter your email to receive a reset link.',
                  style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                ),
                
                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.supaGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(_successMessage!, style: const TextStyle(color: AppColors.supaGreen, fontSize: 14)),
                  ),
                ],

                const SizedBox(height: 32),
                SupaTextField(
                  label: 'Email',
                  placeholder: 'you@example.com',
                  controller: _emailController,
                  isPassword: false,
                ),
                
                if (_mode != AuthMode.forgot) ...[
                  const SizedBox(height: 24),
                  SupaTextField(
                    label: 'Password',
                    placeholder: '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.colorError, fontSize: 12),
                  ),
                ],
                
                const SizedBox(height: 32),
                SupaButton(
                  text: _isLoading 
                    ? 'Loading...' 
                    : (_mode == AuthMode.login ? 'Sign In' : _mode == AuthMode.signup ? 'Sign Up' : 'Send Reset Link'),
                  isLoading: _isLoading,
                  onPressed: _handleAuth,
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      if (_mode == AuthMode.login) ...[
                        TextButton(
                          onPressed: () => setState(() => _mode = AuthMode.signup),
                          child: Text('Don\'t have an account? Sign up', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _mode = AuthMode.forgot),
                          child: Text('Forgot your password?', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ] else if (_mode == AuthMode.signup) ...[
                        TextButton(
                          onPressed: () => setState(() => _mode = AuthMode.login),
                          child: Text('Already have an account? Sign in', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: () => setState(() => _mode = AuthMode.login),
                          child: Text('Back to sign in', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ],
                    ],
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
