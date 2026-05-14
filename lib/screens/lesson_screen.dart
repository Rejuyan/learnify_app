import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../services/local_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/quiz_option.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonScreen extends StatefulWidget {
  final Course course;
  final int lessonIndex;

  const LessonScreen({
    super.key,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _isCompleted = false;
  bool _isLoadingStatus = true;
  bool _isSaving = false;
  late AnimationController _animController;

  final Map<int, int?> _selectedOptions = {};
  final Map<int, bool> _showResults = {};

  YoutubePlayerController? _youtubeController;

  final _ds = LocalDataService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.lessonIndex;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _initYoutubePlayer();
    _checkCompletion();
  }

  void _initYoutubePlayer() {
    final lesson = widget.course.lessons[_currentIndex];
    if (lesson.youtubeVideoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: lesson.youtubeVideoId!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _checkCompletion() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStatus = true;
      _isCompleted = false;
    });

    final lesson = widget.course.lessons[_currentIndex];
    final completed = await _ds.getCompletedLessons(widget.course.id);
    final isDone = completed.contains(lesson.id);

    if (mounted) {
      setState(() {
        _isCompleted = isDone;
        _isLoadingStatus = false;
        if (isDone && lesson.quizzes != null) {
          for (int i = 0; i < lesson.quizzes!.length; i++) {
            _selectedOptions[i] = lesson.quizzes![i].correctIndex;
            _showResults[i] = true;
          }
        }
      });
    }
  }

  Future<void> _markComplete() async {
    if (_isSaving) return;
    final lesson = widget.course.lessons[_currentIndex];
    setState(() {
      _isSaving = true;
      _isCompleted = true;
    });
    try {
      await _ds.markLessonComplete(widget.course.id, lesson.id);
    } catch (_) {
      if (mounted) setState(() => _isCompleted = false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _markIncomplete() async {
    if (_isSaving) return;
    final lesson = widget.course.lessons[_currentIndex];
    setState(() {
      _isSaving = true;
      _isCompleted = false;
    });
    try {
      await _ds.markLessonIncomplete(widget.course.id, lesson.id);
    } catch (_) {
      if (mounted) setState(() => _isCompleted = true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goToLesson(int index) {
    _youtubeController?.dispose();
    _youtubeController = null;
    setState(() {
      _currentIndex = index;
      _selectedOptions.clear();
      _showResults.clear();
      _isCompleted = false;
      _isLoadingStatus = true;
      _animController.reset();
      _animController.forward();
    });
    _initYoutubePlayer();
    _checkCompletion();
  }

  bool get _allQuizzesPassed {
    final lesson = widget.course.lessons[_currentIndex];
    if (lesson.quizzes == null || lesson.quizzes!.isEmpty) return true;
    for (int i = 0; i < lesson.quizzes!.length; i++) {
      if (_selectedOptions[i] != lesson.quizzes![i].correctIndex) return false;
    }
    return true;
  }

  void _selectQuizOption(int quizIndex, int optionIndex) {
    if (_isCompleted) return;
    if (_showResults[quizIndex] == true) return;
    setState(() {
      _selectedOptions[quizIndex] = optionIndex;
      _showResults[quizIndex] = true;
    });
  }

  void _showNotesSheet(BuildContext context) {
    final lesson = widget.course.lessons[_currentIndex];
    final noteController = TextEditingController();
    bool isSaving = false;

    _ds.getNote(lesson.id).then((existing) {
      if (existing != null && noteController.text.isEmpty) {
        noteController.text = existing;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkSurface
          : AppTheme.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.notes_rounded, color: AppTheme.primaryPurple),
                      const SizedBox(width: 10),
                      Text('My Notes', style: Theme.of(context).textTheme.headlineSmall),
                      const Spacer(),
                      Flexible(
                        child: Text(lesson.title,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Jot down your thoughts here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.divider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              await _ds.saveNote(lesson.id, noteController.text);
                              setModalState(() => isSaving = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Note saved!'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded),
                      label: Text(isSaving ? 'Saving...' : 'Save Note'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.course.lessons[_currentIndex];
    final totalLessons = widget.course.lessons.length;
    final lessonProgress = (_currentIndex + 1) / totalLessons;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        floatingActionButton: AuthService().currentUser != null
            ? FloatingActionButton.small(
                backgroundColor: AppTheme.primaryPurple,
                onPressed: () => _showNotesSheet(context),
                tooltip: 'My Notes',
                child: const Icon(Icons.edit_note_rounded, color: Colors.white),
              )
            : null,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Lesson ${_currentIndex + 1} of $totalLessons',
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            if (!_isLoadingStatus)
              IconButton(
                icon: Icon(
                  _isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: _isCompleted ? AppTheme.successGreen : AppTheme.textMuted,
                ),
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_isCompleted) {
                          await _markIncomplete();
                        } else {
                          await _markComplete();
                        }
                      },
                tooltip: _isCompleted ? 'Mark incomplete' : 'Mark complete',
              ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: lessonProgress,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(widget.course.color),
              minHeight: 3,
            ),
            Expanded(
              child: FadeTransition(
                opacity: _animController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0), end: Offset.zero,
                  ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_rounded, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 6),
                            Text('${lesson.durationMinutes} min read',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            if (_isCompleted) ...[
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Completed',
                                    style: TextStyle(
                                      color: AppTheme.successGreen,
                                      fontSize: 11, fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.divider, height: 1),
                        const SizedBox(height: 24),

                        if (_youtubeController != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: YoutubePlayerBuilder(
                              player: YoutubePlayer(
                                controller: _youtubeController!,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: AppTheme.primaryPurple,
                              ),
                              builder: (context, player) => player,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.softCard(borderRadius: 16),
                          child: Text(lesson.content,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),

                        if (lesson.quizzes != null && lesson.quizzes!.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text('Lesson Quiz', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          Text(
                            _isCompleted
                                ? 'All questions answered correctly!'
                                : 'Answer all questions correctly to complete this lesson.',
                            style: TextStyle(
                              color: _isCompleted ? AppTheme.successGreen : AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(lesson.quizzes!.length, (qIndex) {
                            final quiz = lesson.quizzes![qIndex];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: AppTheme.softCard(borderRadius: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Q${qIndex + 1}. ${quiz.question}',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16, fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 16),
                                  ...List.generate(quiz.options.length, (optIndex) {
                                    bool? isCorrect;
                                    if (_showResults[qIndex] == true) {
                                      isCorrect = optIndex == quiz.correctIndex;
                                    }
                                    return QuizOption(
                                      text: quiz.options[optIndex],
                                      index: optIndex,
                                      isSelected: _selectedOptions[qIndex] == optIndex,
                                      isCorrect: isCorrect,
                                      showResult: _showResults[qIndex] == true,
                                      onTap: () => _selectQuizOption(qIndex, optIndex),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
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
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.divider),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _goToLesson(_currentIndex - 1),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.course.color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: AppTheme.divider,
                    ),
                    onPressed: (_isLoadingStatus || _isSaving)
                        ? null
                        : () async {
                            if (!_isCompleted) {
                              // Need to be logged in
                              if (AuthService().currentUser == null) {
                                await Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()));
                                return;
                              }
                              if (!_allQuizzesPassed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Answer all quiz questions correctly to proceed.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                                return;
                              }
                              await _markComplete();
                            }
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            if (_currentIndex < totalLessons - 1) {
                              _goToLesson(_currentIndex + 1);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                    child: (_isLoadingStatus || _isSaving)
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            _currentIndex < totalLessons - 1
                                ? (_isCompleted ? 'Next Lesson' : 'Complete & Next')
                                : (_isCompleted ? 'Finish Course' : 'Complete & Finish'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
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
