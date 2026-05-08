import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_indicator_widget.dart';

class ProgressScreen extends StatefulWidget {
  final VoidCallback? onRefresh;

  const ProgressScreen({super.key, this.onRefresh});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic> _stats = {};
  Map<String, double> _courseProgress = {};
  Map<String, Map<String, int>?> _quizScores = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final courseIds = sampleCourses.map((c) => c.id).toList();
    final lessonCounts = {
      for (final c in sampleCourses) c.id: c.totalLessons
    };
    final stats =
        await ProgressService.getOverallStats(courseIds, lessonCounts);

    final Map<String, double> progress = {};
    final Map<String, Map<String, int>?> quizScores = {};
    for (final course in sampleCourses) {
      progress[course.id] = await ProgressService.getCourseProgress(
          course.id, course.totalLessons);
      quizScores[course.id] =
          await ProgressService.getQuizScore(course.id);
    }

    if (mounted) {
      setState(() {
        _stats = stats;
        _courseProgress = progress;
        _quizScores = quizScores;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryPurple),
      );
    }

    final overallProgress = (_stats['overallProgress'] as double? ?? 0.0);
    final lessonsCompleted = _stats['lessonsCompleted'] as int? ?? 0;
    final totalLessons = _stats['totalLessons'] as int? ?? 0;
    final quizzesTaken = _stats['quizzesTaken'] as int? ?? 0;
    final totalQuizScore = _stats['totalQuizScore'] as int? ?? 0;
    final totalQuizQuestions = _stats['totalQuizQuestions'] as int? ?? 0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadStats();
          widget.onRefresh?.call();
        },
        color: AppTheme.primaryPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Track your learning journey',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 28),

              // ─── Overall Stats Card ─────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.08),
                      AppTheme.primaryPurpleLight.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ),
                  boxShadow: AppTheme.cardShadowLight,
                ),
                child: Column(
                  children: [
                    AnimatedCircularProgress(
                      progress: overallProgress,
                      size: 110,
                      strokeWidth: 8,
                      progressColor: AppTheme.primaryPurple,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(overallProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Complete',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          Icons.menu_book_rounded,
                          '$lessonsCompleted/$totalLessons',
                          'Lessons',
                          AppTheme.courseTeal,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.divider,
                        ),
                        _buildStatColumn(
                          Icons.quiz_rounded,
                          '$quizzesTaken/${sampleCourses.length}',
                          'Quizzes',
                          AppTheme.accentOrange,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.divider,
                        ),
                        _buildStatColumn(
                          Icons.stars_rounded,
                          totalQuizQuestions > 0
                              ? '${((totalQuizScore / totalQuizQuestions) * 100).toInt()}%'
                              : '-',
                          'Avg Score',
                          AppTheme.coursePink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ─── Per-Course Progress ────────────────
              Text(
                'Course Progress',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              ...sampleCourses.map((course) {
                final progress = _courseProgress[course.id] ?? 0.0;
                final quiz = _quizScores[course.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.softCard(borderRadius: 16),
                    child: Row(
                      children: [
                        AnimatedCircularProgress(
                          progress: progress,
                          size: 52,
                          strokeWidth: 4,
                          progressColor: course.color,
                          center: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quiz != null
                                    ? 'Quiz: ${quiz['score']}/${quiz['total']}'
                                    : 'Quiz not taken',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          progress >= 1.0
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: progress >= 1.0
                              ? AppTheme.successGreen
                              : AppTheme.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Reset button
              Center(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                  label: const Text(
                    'Reset All Progress',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: _showResetDialog,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Reset Progress?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will clear all your lesson completions and quiz scores. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ProgressService.resetAllProgress();
              _loadStats();
              widget.onRefresh?.call();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
