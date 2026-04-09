import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/auth_service.dart';
import '../../services/local_data_service.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';
import '../home_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (credential?.user != null) {
        await LocalDataService().syncWithCloud();
        
        if (!mounted) return;

        Widget nextScreen = const HomeScreen();
        if (credential?.user?.email == 'admin@learnify.com') {
          nextScreen = const AdminDashboardScreen();
        }

        // Navigate to the dashboard, clearing the entire back stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => nextScreen),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_m5al1gqg.json',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.lock_person_rounded,
                          size: 80, color: AppTheme.primaryPurple);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Welcome Back',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Log in to access quizzes and track your progress.',
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!,
                      style: TextStyle(color: Colors.red.shade700)),
                ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Log In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text('Register',
                        style: TextStyle(
                            color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
