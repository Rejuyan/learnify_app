import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/course.dart';
import '../services/local_data_service.dart';
import '../services/auth_service.dart';
import '../services/certificate_pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'trophy_room_screen.dart';
import '../utils/network_simulator.dart';

class MyLearningScreen extends StatefulWidget {
  final VoidCallback? onRefreshParent;
  const MyLearningScreen({super.key, this.onRefreshParent});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  List<Course> _enrolledCourses = [];
  Map<String, double> _progress = {};
  Map<String, Map<String, int>?> _quizScores = {};
  bool _isLoading = true;
  String? _downloadingId;

  final _ds = LocalDataService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await updateCoursesFromFirestore();
    await _ds.syncWithCloud();

    final enrolledIds = await _ds.getEnrolledCourseIds();
    final enrolled = sampleCourses.where((c) => enrolledIds.contains(c.id)).toList();

    final Map<String, double> progress = {};
    final Map<String, Map<String, int>?> quizScores = {};
    for (final c in enrolled) {
      progress[c.id] = await _ds.getCourseProgress(c.id, c.totalLessons);
      quizScores[c.id] = await _ds.getQuizScore(c.id);
    }

    if (mounted) {
      setState(() {
        _enrolledCourses = enrolled;
        _progress = progress;
        _quizScores = quizScores;
        _isLoading = false;
      });
    }
  }

  String get _userName {
    final user = AuthService().currentUser;
    if (user == null) return 'Learner';
    final displayName = user.displayName;
    if (displayName != null && displayName.isNotEmpty) return displayName;
    if (user.email != null) {
      final name = user.email!.split('@')[0];
      if (name.isNotEmpty) return name[0].toUpperCase() + name.substring(1);
    }
    return 'Learner';
  }

  Future<void> _downloadCertificate(Course course) async {
    setState(() => _downloadingId = course.id);
    try {
      final quiz = _quizScores[course.id];
      final now = DateTime.now();
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final dateStr = '${months[now.month]} ${now.day}, ${now.year}';

      final savedPath = await CertificatePdfService.saveToDevice(
        studentName: _userName,
        courseTitle: course.title,
        score: quiz?['score'] ?? course.quizzes.length,
        totalQuestions: quiz?['total'] ?? course.quizzes.length,
        earnedDate: dateStr,
        context: context,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Certificate saved!\n$savedPath',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save PDF: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple));
    }

    if (_enrolledCourses.isEmpty) {
      return _buildEmpty(context);
    }

    final completedCourses = _enrolledCourses.where((c) => (_progress[c.id] ?? 0) >= 1.0).toList();
    final inProgressCourses = _enrolledCourses.where((c) => (_progress[c.id] ?? 0) < 1.0).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Learning', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${_enrolledCourses.length} enrolled  •  ${completedCourses.length} completed',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Trophy room shortcut
              if (completedCourses.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    await NetworkSimulator.delay(context);
                    if (mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrophyRoomScreen()));
                    }
                  },
                  icon: const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFFFD93D)),
                  label: const Text('Trophies',
                      style: TextStyle(color: Color(0xFFFFD93D), fontSize: 12)),
                ),
            ],
          ),

          // ── In progress ──────────────────────────────
          if (inProgressCourses.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('In Progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: inProgressCourses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final course = inProgressCourses[index];
                return CourseCard(
                  course: course,
                  progress: _progress[course.id] ?? 0.0,
                  onTap: () async {
                    await NetworkSimulator.delay(context);
                    if (mounted) {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)));
                      _loadData();
                      widget.onRefreshParent?.call();
                    }
                  },
                );
              },
            ),
          ],

          // ── Completed ─────────────────────────────────
          if (completedCourses.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: AppTheme.successGreen),
                const SizedBox(width: 6),
                const Text('Completed',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen)),
              ],
            ),
            const SizedBox(height: 12),
            ...completedCourses.map((course) {
              final quiz = _quizScores[course.id];
              final efficiency = quiz != null && quiz['total']! > 0
                  ? ((quiz['score']! / quiz['total']!) * 100).toInt()
                  : 100;
              final isDownloading = _downloadingId == course.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      course.color.withValues(alpha: 0.08),
                      AppTheme.surfaceCard,
                    ],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3), width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Course icon
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: course.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(course.icon, color: course.color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14, fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 12, color: AppTheme.successGreen),
                              const SizedBox(width: 4),
                              Text('$efficiency% efficiency',
                                  style: const TextStyle(
                                    color: AppTheme.successGreen, fontSize: 12,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Download PDF button
                          SizedBox(
                            width: double.infinity,
                            height: 34,
                            child: ElevatedButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () => _downloadCertificate(course),
                              icon: isDownloading
                                  ? const SizedBox(width: 12, height: 12,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Color(0xFF1A1040)))
                                  : const Icon(Icons.save_alt_rounded, size: 14),
                              label: Text(
                                isDownloading ? 'Saving...' : 'Save Certificate',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD93D),
                                foregroundColor: const Color(0xFF1A1040),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 80, color: AppTheme.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 20),
            const Text('No Courses Yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
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
