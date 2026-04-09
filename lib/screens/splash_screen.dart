import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import 'landing_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late AnimationController _textController;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500), vsync: this,
    );
    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000), vsync: this,
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));
    _textFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToNext();
  }

  void _navigateToNext() {
    if (!mounted) return;
    final user = AuthService().currentUser;
    Widget nextScreen = const LandingScreen();
    if (user != null) {
      if (user.email == 'admin@learnify.com') {
        nextScreen = const AdminDashboardScreen();
      } else {
        nextScreen = const HomeScreen();
      }
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => nextScreen,
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100, right: -100,
              child: _buildBlurCircle(300, Colors.white.withValues(alpha: 0.1)),
            ),
            Positioned(
              bottom: -50, left: -50,
              child: _buildBlurCircle(200, Colors.white.withValues(alpha: 0.05)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20, offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Lottie.network(
                            'https://assets3.lottiefiles.com/packages/lf20_drow7d1i.json',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.school_rounded,
                                  size: 80, color: Color(0xFF2575FC));
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          const Text('Learnify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48, fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
                                ],
                              )),
                          const SizedBox(height: 8),
                          Text('Empowering Your Future',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16, fontWeight: FontWeight.w300, letterSpacing: 2,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 60, left: 0, right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40, height: 2,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Preparing your journey...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          )),
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

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
