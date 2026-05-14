import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lesson_tile.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

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
  bool _isTogglingEnroll = false;
  late AnimationController _animController;

  final _ds = LocalDataService();

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
    final completed = await _ds.getCompletedLessons(widget.course.id);
    final quizScore = await _ds.getQuizScore(widget.course.id);
    final enrolled = await _ds.isEnrolled(widget.course.id);

    if (mounted) {
      setState(() {
        _completedLessons = completed;
        _quizScore = quizScore;
        _isEnrolled = enrolled;
      });
    }
  }

  Future<void> _toggleEnroll() async {
    if (_isTogglingEnroll) return;
    setState(() {
      _isTogglingEnroll = true;
      _isEnrolled = !_isEnrolled; // optimistic
    });
    try {
      if (!_isEnrolled) {
        // We just set it to false (was true), so unenroll
        await _ds.unenrollCourse(widget.course.id);
      } else {
        await _ds.enrollCourse(widget.course.id);
      }
    } catch (_) {
      if (mounted) setState(() => _isEnrolled = !_isEnrolled); // revert
    } finally {
      if (mounted) setState(() => _isTogglingEnroll = false);
    }
  }

  int get _firstIncompleteLessonIndex {
    for (int i = 0; i < widget.course.lessons.length; i++) {
      if (!_completedLessons.contains(widget.course.lessons[i].id)) return i;
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
            // ─── Hero Header ───────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: widget.course.color,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                        widget.course.color.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.course.category,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.course.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.course.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Enroll Button ─────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _isEnrolled
                          ? OutlinedButton.icon(
                              icon: _isTogglingEnroll
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.check_rounded),
                              label: const Text('Enrolled'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: widget.course.color,
                                side: BorderSide(color: widget.course.color),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _isTogglingEnroll ? null : _toggleEnroll,
                            )
                          : ElevatedButton.icon(
                              icon: _isTogglingEnroll
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.school_rounded),
                              label: const Text('Enroll This Course'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.course.color,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _isTogglingEnroll ? null : _toggleEnroll,
                            ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Stats ─────────────────────────
                    Row(
                      children: [
                        _buildStat(Icons.menu_book_rounded,
                            '${widget.course.totalLessons}', 'Lessons', widget.course.color),
                        _buildStat(Icons.timer_rounded,
                            '${widget.course.lessons.fold(0, (sum, l) => sum + l.durationMinutes)}m',
                            'Duration', AppTheme.courseTeal),
                        _buildStat(Icons.quiz_rounded,
                            '${widget.course.quizzes.length}', 'Quizzes', AppTheme.accentOrange),
                        _buildStat(Icons.bar_chart_rounded,
                            '${(_progress * 100).toInt()}%', 'Done', AppTheme.successGreen),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ─── Progress bar ──────────────────
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

                    // ─── Lessons ───────────────────────
                    Text('Lessons', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 14),

                    ...List.generate(widget.course.lessons.length, (i) {
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
                    }),

                    const SizedBox(height: 24),

                    // ─── Quiz section ──────────────────
                    Text('Final Quiz', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 14),
                    _buildQuizCard(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── Start / Continue Button ───────────────────
        bottomNavigationBar: _isEnrolled
            ? Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10, offset: const Offset(0, -2),
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
                        final lessonIndex = _firstIncompleteLessonIndex >= 0
                            ? _firstIncompleteLessonIndex
                            : 0;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonScreen(
                              course: widget.course,
                              lessonIndex: lessonIndex,
                            ),
                          ),
                        );
                        _loadProgress();
                      },
                      child: Text(
                        _completedLessons.isEmpty
                            ? 'Start Learning'
                            : _firstIncompleteLessonIndex >= 0
                                ? 'Continue Learning'
                                : 'Review Course',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          Text(value,
              style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    final hasTaken = _quizScore != null;
    return GestureDetector(
      onTap: () async {
        if (widget.course.quizzes.isEmpty) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuizScreen(course: widget.course)),
        );
        _loadProgress();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.softCard(),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
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
                    hasTaken ? 'Quiz Completed' : 'Take Final Quiz',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasTaken
                        ? 'Score: ${_quizScore!['score']}/${_quizScore!['total']}'
                        : '${widget.course.quizzes.length} questions',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: hasTaken ? AppTheme.successGreen : AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
