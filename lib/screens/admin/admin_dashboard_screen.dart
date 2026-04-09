import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_data_service.dart';
import '../../data/sample_data.dart';
import '../home_screen.dart';
import '../auth/login_screen.dart';
import 'course_edit_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isSeeding = false;
  bool _isRefreshing = false;
  final _ds = LocalDataService();

  int get totalLessons => sampleCourses.fold(0, (sum, c) => sum + c.totalLessons);
  int get totalQuizzes => sampleCourses.fold(0, (sum, c) => sum + c.totalQuizzes);
  Set<String> get totalCategories => sampleCourses.map((c) => c.category).toSet();

  Future<void> _refreshStats() async {
    setState(() => _isRefreshing = true);
    await updateCoursesFromFirestore();
    setState(() => _isRefreshing = false);
  }

  Future<void> _seedDatabase() async {
    if (_isSeeding) return;
    setState(() => _isSeeding = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seeding Firestore Database... Please wait.'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );

    try {
      await FirestoreService().uploadSampleCoursesToFirestore();
      await updateCoursesFromFirestore();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firestore Database successfully seeded! All courses are online.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to seed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Future<void> _flushCache() async {
    await _ds.resetAllProgress();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SharedPreferences development cache cleared successfully.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final email = user?.email ?? 'admin@learnify.com';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A16), // Ultra Premium Dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.dashboard_customize_rounded, color: AppTheme.primaryPurpleLight, size: 24),
            const SizedBox(width: 10),
            const Text(
              'LEARNIFY CONSOLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.15),
                border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.4), width: 1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: AppTheme.accentOrange,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isRefreshing 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _isRefreshing ? null : _refreshStats,
            tooltip: 'Sync catalog stats',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back, Command',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.split('@')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await AuthService().signOut();
                    await _ds.resetAllProgress();
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.12),
                      border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3), width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistics Grid (2x2)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  title: 'ACTIVE COURSES',
                  value: '${sampleCourses.length}',
                  icon: Icons.layers_rounded,
                  color: AppTheme.primaryPurpleLight,
                ),
                _buildStatCard(
                  title: 'VIDEO LECTURES',
                  value: '$totalLessons',
                  icon: Icons.video_library_rounded,
                  color: AppTheme.courseTeal,
                ),
                _buildStatCard(
                  title: 'QUIZ QUESTIONS',
                  value: '$totalQuizzes',
                  icon: Icons.help_outline_rounded,
                  color: AppTheme.coursePink,
                ),
                _buildStatCard(
                  title: 'CATEGORIES',
                  value: '${totalCategories.length}',
                  icon: Icons.category_rounded,
                  color: AppTheme.courseAmber,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions Panel
            const Text(
              'QUICK ACTIONS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Create New Course',
              subtitle: 'Add a new dynamic course with custom lessons and quizzes',
              icon: Icons.add_to_photos_rounded,
              color: AppTheme.courseTeal,
              onTap: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CourseEditScreen(),
                  ),
                );
                if (refresh == true) {
                  _refreshStats();
                }
              },
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              title: 'Seed Firestore Database',
              subtitle: 'Populate Firebase with default premium courses & quizzes',
              icon: Icons.cloud_upload_rounded,
              color: AppTheme.primaryPurpleLight,
              onTap: _seedDatabase,
              trailing: _isSeeding 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : null,
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              title: 'Enter Student Preview Mode',
              subtitle: 'Preview the dynamic course catalog exactly as a user',
              icon: Icons.visibility_rounded,
              color: AppTheme.courseTeal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              title: 'Flush Development Cache',
              subtitle: 'Clear SharedPreferences progress caches safely',
              icon: Icons.delete_sweep_rounded,
              color: AppTheme.coursePink,
              onTap: _flushCache,
            ),
            const SizedBox(height: 32),

            // Live Catalog
            const Text(
              'LIVE CATALOG BREAKDOWN',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            sampleCourses.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16162E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.layers_clear_rounded, color: Colors.white24, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'Catalog Empty / Synced Out',
                          style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Click Seed Firestore above to populate dynamic database.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sampleCourses.length,
                    itemBuilder: (context, index) {
                      final course = sampleCourses[index];
                      return GestureDetector(
                        onTap: () async {
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseEditScreen(course: course),
                            ),
                          );
                          if (refresh == true) {
                            _refreshStats();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16162E), // dark card style
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: course.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(course.icon, color: course.color, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          course.category.toUpperCase(),
                                          style: TextStyle(color: course.color, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('•', style: TextStyle(color: Colors.white24)),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${course.totalLessons} Lectures',
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                                  border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3), width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      'ONLINE',
                                      style: TextStyle(color: AppTheme.successGreen, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162E), // Glassmorphic look
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, color: color.withValues(alpha: 0.7), size: 18),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16162E),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
          ],
        ),
      ),
    );
  }
}
