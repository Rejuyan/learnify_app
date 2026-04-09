import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../data/sample_data.dart';
import 'auth/login_screen.dart';
import '../utils/network_simulator.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _navigateToLogin() async {
    await NetworkSimulator.delay(context);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero Section ─────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.55,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: AppTheme.primaryPurple, size: 28),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Learnify',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Master New Skills\nAnywhere, Anytime',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E2E),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Join thousands of learners unlocking their potential through curated courses and verified certificates.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF333333),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryPurple,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 8,
                                      shadowColor: AppTheme.primaryPurple.withValues(alpha: 0.5),
                                    ),
                                    onPressed: _navigateToLogin,
                                    child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryPurple,
                                      side: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                                    ),
                                    onPressed: _navigateToLogin,
                                    child: const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // ─── Features Overview ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why choose Learnify?',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureCard(
                      icon: Icons.auto_awesome_mosaic_rounded,
                      color: Colors.blue,
                      title: 'Diverse Course Catalog',
                      description: 'Explore programming, design, business, and more from expert instructors.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.workspace_premium_rounded,
                      color: const Color(0xFFFFD93D),
                      title: 'Verified Certificates',
                      description: 'Earn downloadable, shareable certificates to showcase your achievements.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.speed_rounded,
                      color: AppTheme.successGreen,
                      title: 'Learn at your Pace',
                      description: 'Track your progress and learn comfortably without any deadlines.',
                    ),
                  ],
                ),
              ),
            ),

            // ─── Popular Courses Preview ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trending Courses',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 3, // show top 3
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final course = sampleCourses[index];
                          return Container(
                            width: 260,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: course.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: course.color.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: course.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(course.icon, color: course.color, size: 28),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${course.totalLessons} lessons • ${course.category}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required Color color, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
