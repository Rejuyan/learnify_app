import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../services/progress_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lesson_tile.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'certificate_screen.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'auth/verify_email_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  List<String> _completedLessons = [];
  Map<String, int>? _quizScore;
  bool _isEnrolled = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _loadProgress();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final firestoreService = FirestoreService();
    final isCloud = firestoreService.isLoggedIn;

    final completed = isCloud
        ? await firestoreService.getCompletedLessons(widget.course.id)
        : await ProgressService.getCompletedLessons(widget.course.id);
    final quizScore = isCloud
        ? await firestoreService.getQuizScore(widget.course.id)
        : await ProgressService.getQuizScore(widget.course.id);
    final enrolled = isCloud
        ? await firestoreService.isEnrolled(widget.course.id)
        : false;

    if (mounted) {
      setState(() {
        _completedLessons = completed;
        _quizScore = quizScore;
        _isEnrolled = enrolled;
      });
    }
  }

  Future<void> _toggleEnroll() async {
    if (!FirestoreService().isLoggedIn) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    
    // Optimistic UI update
    final wasEnrolled = _isEnrolled;
    setState(() => _isEnrolled = !wasEnrolled);
    
    try {
      if (wasEnrolled) {
        await FirestoreService().unenrollCourse(widget.course.id);
      } else {
        await FirestoreService().enrollCourse(widget.course.id);
      }
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() => _isEnrolled = wasEnrolled);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update enrollment: $e')),
        );
      }
    }
  }

  int get _firstIncompleteLessonIndex {
    for (int i = 0; i < widget.course.lessons.length; i++) {
      if (!_completedLessons.contains(widget.course.lessons[i].id)) {
        return i;
      }
    }
    return -1;
  }

  double get _progress {
    if (widget.course.totalLessons == 0) return 0;
    return _completedLessons.length / widget.course.totalLessons;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero Header ──────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: widget.course.color,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.course.color,
                        widget.course.gradientEnd,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              widget.course.icon,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.course.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.course.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Body ──────────────────────────────────
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animController,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: _animController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Text(
                          widget.course.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // Enroll Button
                        if (AuthService().currentUser != null)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            child: _isEnrolled
                                ? OutlinedButton.icon(
                                    onPressed: _toggleEnroll,
                                    icon: const Icon(Icons.bookmark_remove_rounded),
                                    label: const Text('Enrolled ✓'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: widget.course.color,
                                      side: BorderSide(color: widget.course.color),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: _toggleEnroll,
                                    icon: const Icon(Icons.bookmark_add_rounded),
                                    label: const Text('Enroll in Course'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.course.color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                          ),

                        const SizedBox(height: 20),

                        // Stats row
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.softCard(),
                          child: Row(
                            children: [
                              _buildStat(Icons.menu_book_rounded,
                                  '${widget.course.totalLessons}', 'Lessons',
                                  AppTheme.primaryPurple),
                              Container(width: 1, height: 30, color: AppTheme.divider),
                              _buildStat(Icons.quiz_rounded,
                                  '${widget.course.totalQuizzes}', 'Quizzes',
                                  AppTheme.accentOrange),
                              Container(width: 1, height: 30, color: AppTheme.divider),
                              _buildStat(Icons.trending_up_rounded,
                                  '${(_progress * 100).toInt()}%', 'Done',
                                  AppTheme.successGreen),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: AppTheme.divider,
                            valueColor: AlwaysStoppedAnimation(widget.course.color),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Lessons header
                        Text(
                          'Lessons',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 14),

                        // Lesson list
                        ...List.generate(
                          widget.course.lessons.length,
                          (i) {
                            final lesson = widget.course.lessons[i];
                            final isCompleted = _completedLessons.contains(lesson.id);
                            final isCurrent = i == _firstIncompleteLessonIndex;
                            return LessonTile(
                              title: lesson.title,
                              durationMinutes: lesson.durationMinutes,
                              index: i,
                              isCompleted: isCompleted,
                              isCurrent: isCurrent,
                              accentColor: widget.course.color,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LessonScreen(
                                      course: widget.course,
                                      lessonIndex: i,
                                    ),
                                  ),
                                );
                                _loadProgress();
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Quiz section
                        Text(
                          'Quiz',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 14),
                        _buildQuizCard(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // ─── Continue Button ──────────────────────────
        bottomNavigationBar: _firstIncompleteLessonIndex >= 0
            ? Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.course.color,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonScreen(
                              course: widget.course,
                              lessonIndex: _firstIncompleteLessonIndex,
                            ),
                          ),
                        );
                        _loadProgress();
                      },
                      child: const Text(
                        'Continue Learning',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    final hasTaken = _quizScore != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.softCard(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasTaken
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : widget.course.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              hasTaken ? Icons.check_circle_rounded : Icons.quiz_rounded,
              color: hasTaken ? AppTheme.successGreen : widget.course.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasTaken ? 'Quiz Completed' : 'Course Quiz',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasTaken
                      ? 'Score: ${_quizScore!['score']}/${_quizScore!['total']}'
                      : '${widget.course.totalQuizzes} questions',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.course.color,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              final authService = AuthService();
              final user = authService.currentUser;
              
              if (user == null) {
                // Not logged in
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
                return;
              }
              
              if (!user.emailVerified) {
                // Logged in but not verified
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
                );
                return;
              }

              if (_completedLessons.length < widget.course.totalLessons) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please complete all lessons and their quizzes before taking the final assessment.'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(course: widget.course),
                ),
              );
              await _loadProgress();
              // Award certificate if course is now fully complete
              if (mounted && _progress >= 1.0) {
                final alreadyHas = await FirestoreService().hasCertificate(widget.course.id);
                if (!alreadyHas && mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CertificateScreen(
                        courseTitle: widget.course.title,
                        courseId: widget.course.id,
                        isNewlyEarned: true,
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              hasTaken ? 'Retake' : 'Start',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
