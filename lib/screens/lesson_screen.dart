import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/quiz_option.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'auth/login_screen.dart';
import 'auth/verify_email_screen.dart';
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
  late AnimationController _animController;
  
  // Quiz state
  final Map<int, int?> _selectedOptions = {};
  final Map<int, bool> _showResults = {};
  
  // Video state
  YoutubePlayerController? _youtubeController;

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
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
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
    setState(() => _isLoadingStatus = true);
    final lesson = widget.course.lessons[_currentIndex];
    final isCloud = FirestoreService().isLoggedIn;
    
    try {
      final completed = isCloud
          ? (await FirestoreService().getCompletedLessons(widget.course.id))
              .contains(lesson.id)
          : await ProgressService.isLessonComplete(widget.course.id, lesson.id);
      
      if (mounted) {
        setState(() {
          _isCompleted = completed;
          _isLoadingStatus = false;
          if (completed && lesson.quizzes != null) {
            for (int i = 0; i < lesson.quizzes!.length; i++) {
              _selectedOptions[i] = lesson.quizzes![i].correctIndex;
              _showResults[i] = true;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _toggleComplete() async {
    final lesson = widget.course.lessons[_currentIndex];
    final isCloud = FirestoreService().isLoggedIn;
    if (_isCompleted) {
      if (isCloud) {
        await FirestoreService().markLessonIncomplete(widget.course.id, lesson.id);
      } else {
        await ProgressService.markLessonIncomplete(widget.course.id, lesson.id);
      }
    } else {
      if (isCloud) {
        await FirestoreService().markLessonComplete(widget.course.id, lesson.id);
      } else {
        await ProgressService.markLessonComplete(widget.course.id, lesson.id);
      }
    }
    setState(() => _isCompleted = !_isCompleted);
  }

  void _goToLesson(int index) {
    setState(() {
      _currentIndex = index;
      _selectedOptions.clear();
      _showResults.clear();
      _animController.reset();
      _animController.forward();
      
      _youtubeController?.dispose();
      _youtubeController = null;
      _initYoutubePlayer();
    });
    _checkCompletion();
  }

  bool get _allQuizzesPassed {
    final lesson = widget.course.lessons[_currentIndex];
    if (lesson.quizzes == null || lesson.quizzes!.isEmpty) return true;
    for (int i = 0; i < lesson.quizzes!.length; i++) {
      if (_selectedOptions[i] != lesson.quizzes![i].correctIndex) {
        return false;
      }
    }
    return true;
  }

  void _selectQuizOption(int quizIndex, int optionIndex) {
    setState(() {
      _selectedOptions[quizIndex] = optionIndex;
      _showResults[quizIndex] = true;
    });

    // Auto-advance logic: If all quizzes are now passed, automatically mark complete and move on
    if (_allQuizzesPassed && !_isCompleted) {
      Future.delayed(const Duration(milliseconds: 1200), () async {
        if (mounted && _allQuizzesPassed && !_isCompleted) {
          await _toggleComplete();
          // After completing, go to next lesson automatically if not the last one
          if (mounted) {
            final totalLessons = widget.course.lessons.length;
            if (_currentIndex < totalLessons - 1) {
              _goToLesson(_currentIndex + 1);
            }
          }
        }
      });
    }
  }

  void _showNotesSheet(BuildContext context) {
    final lesson = widget.course.lessons[_currentIndex];
    final noteController = TextEditingController();
    bool isSaving = false;

    // Load existing note
    FirestoreService().getNote(lesson.id).then((existing) {
      if (existing != null) noteController.text = existing;
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
                      Text('My Notes',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Spacer(),
                      Text(lesson.title,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
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
                              await FirestoreService()
                                  .saveNote(lesson.id, noteController.text);
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
    final progress = (_currentIndex + 1) / totalLessons;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        floatingActionButton: FirestoreService().isLoggedIn
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: _isCompleted
                    ? AppTheme.successGreen
                    : AppTheme.textMuted,
              ),
              onPressed: () async {
                final authService = AuthService();
                final user = authService.currentUser;
                
                if (user == null) {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  return;
                }
                if (!user.emailVerified) {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
                  return;
                }

                if (!_isCompleted && !_allQuizzesPassed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please answer all quizzes correctly first.'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }
                _toggleComplete();
              },
              tooltip: _isCompleted ? 'Mark incomplete' : 'Mark complete',
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation<Color>(widget.course.color),
                minHeight: 3,
              ),
            ),

            // Lesson content
            Expanded(
              child: FadeTransition(
                opacity: _animController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animController,
                    curve: Curves.easeOut,
                  )),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lesson title
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_rounded,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${lesson.durationMinutes} min read',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            if (_isCompleted) ...[
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.divider, height: 1),
                        const SizedBox(height: 24),
                        
                        // Video Player
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

                        // Content in a white card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.softCard(borderRadius: 16),
                          child: Text(
                            lesson.content,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        
                        // Lesson Quizzes
                        if (lesson.quizzes != null && lesson.quizzes!.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text(
                            'Lesson Quiz',
                            style: Theme.of(context).textTheme.headlineSmall,
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
                                  Text(
                                    'Q${qIndex + 1}. ${quiz.question}',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

        // ─── Bottom Nav ──────────────────────────────
        bottomNavigationBar: Container(
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
            child: Row(
              children: [
                // Previous
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.divider),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _goToLesson(_currentIndex - 1),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                // Complete & Next / Done
                 Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.course.color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: AppTheme.divider,
                    ),
                    onPressed: _isLoadingStatus 
                      ? null 
                      : () async {
                        if (!_isCompleted) {
                          final authService = AuthService();
                          final user = authService.currentUser;
                          
                          if (user == null) {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            return;
                          }
                          if (!user.emailVerified) {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
                            return;
                          }

                          if (!_allQuizzesPassed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please answer all lesson quizzes correctly to proceed.'),
                                backgroundColor: AppTheme.errorRed,
                              ),
                            );
                            return;
                          }
                          await _toggleComplete();
                        }
                        
                        // Proceed to next or finish
                        if (_currentIndex < totalLessons - 1) {
                          _goToLesson(_currentIndex + 1);
                        } else {
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                    child: _isLoadingStatus
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          _currentIndex < totalLessons - 1
                              ? (_isCompleted ? 'Next Lesson' : 'Complete & Next')
                              : 'Finish Course',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
