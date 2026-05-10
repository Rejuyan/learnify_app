import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';
import '../services/progress_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'auth/login_screen.dart';

class MyLearningScreen extends StatefulWidget {
  final VoidCallback? onRefreshParent;
  const MyLearningScreen({super.key, this.onRefreshParent});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  List<Course> _enrolledCourses = [];
  Map<String, double> _progress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = AuthService().currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final enrolledIds = await FirestoreService().getEnrolledCourseIds();
    final enrolled = sampleCourses.where((c) => enrolledIds.contains(c.id)).toList();

    final Map<String, double> progress = {};
    for (final c in enrolled) {
      final p = FirestoreService().isLoggedIn
          ? await FirestoreService().getCourseProgress(c.id, c.totalLessons)
          : await ProgressService.getCourseProgress(c.id, c.totalLessons);
      progress[c.id] = p;
    }

    setState(() {
      _enrolledCourses = enrolled;
      _progress = progress;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return _buildNotLoggedIn(context);
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_enrolledCourses.isEmpty) {
      return _buildEmpty(context, isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'My Learning',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${_enrolledCourses.length} course${_enrolledCourses.length == 1 ? '' : 's'} enrolled',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: _enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = _enrolledCourses[index];
              return CourseCard(
                course: course,
                progress: _progress[course.id] ?? 0.0,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(course: course)),
                  );
                  _loadData();
                  widget.onRefreshParent?.call();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Log in to see your courses',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 80,
                color: AppTheme.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 20),
            const Text(
              'No Courses Yet',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse the Home tab and enroll in a course\nto start your learning journey!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
