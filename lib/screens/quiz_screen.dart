import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/quiz_option.dart';

import '../services/firestore_service.dart';

class QuizScreen extends StatefulWidget {
  final Course course;

  const QuizScreen({super.key, required this.course});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _showResult = false;
  int _correctCount = 0;
  bool _quizFinished = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_showResult) return;
    setState(() => _selectedOption = index);
  }

  void _checkAnswer() {
    final quiz = widget.course.quizzes[_currentQuestion];
    setState(() {
      _showResult = true;
      if (_selectedOption == quiz.correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.course.quizzes.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
        _showResult = false;
        _animController.reset();
        _animController.forward();
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final firestoreService = FirestoreService();
    if (firestoreService.isLoggedIn) {
      await firestoreService.saveQuizScore(
        widget.course.id,
        _correctCount,
        widget.course.quizzes.length,
      );
    } else {
      await ProgressService.saveQuizScore(
        widget.course.id,
        _correctCount,
        widget.course.quizzes.length,
      );
    }
    setState(() => _quizFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_quizFinished) return _buildResultScreen();
    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    final quiz = widget.course.quizzes[_currentQuestion];
    final totalQuestions = widget.course.quizzes.length;
    final progress = (_currentQuestion + 1) / totalQuestions;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
            onPressed: _showExitDialog,
          ),
          title: Text(
            'Question ${_currentQuestion + 1} of $totalQuestions',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        body: Column(
          children: [
            // Progress
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation<Color>(widget.course.color),
                minHeight: 3,
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _animController,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Question
                      Text(
                        quiz.question,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Options
                      ...List.generate(quiz.options.length, (i) {
                        bool? isCorrect;
                        if (_showResult) {
                          isCorrect = i == quiz.correctIndex;
                        }
                        return QuizOption(
                          text: quiz.options[i],
                          index: i,
                          isSelected: _selectedOption == i,
                          isCorrect: isCorrect,
                          showResult: _showResult,
                          onTap: _showResult ? null : () => _selectOption(i),
                        );
                      }),

                      // Feedback
                      if (_showResult) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (_selectedOption == quiz.correctIndex)
                                ? AppTheme.successGreen.withValues(alpha: 0.08)
                                : AppTheme.errorRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (_selectedOption == quiz.correctIndex)
                                  ? AppTheme.successGreen.withValues(alpha: 0.2)
                                  : AppTheme.errorRed.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (_selectedOption == quiz.correctIndex)
                                    ? Icons.celebration_rounded
                                    : Icons.info_outline_rounded,
                                color: (_selectedOption == quiz.correctIndex)
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  (_selectedOption == quiz.correctIndex)
                                      ? 'Correct! Great job! \u{1F389}'
                                      : 'The correct answer is: ${quiz.options[quiz.correctIndex]}',
                                  style: TextStyle(
                                    color: (_selectedOption == quiz.correctIndex)
                                        ? AppTheme.successGreen
                                        : AppTheme.errorRed,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
                  backgroundColor: _showResult
                      ? widget.course.color
                      : AppTheme.primaryPurple,
                  disabledBackgroundColor: AppTheme.divider,
                ),
                onPressed: _selectedOption == null
                    ? null
                    : (_showResult ? _nextQuestion : _checkAnswer),
                child: Text(
                  _showResult
                      ? (_currentQuestion < widget.course.quizzes.length - 1
                          ? 'Next Question'
                          : 'See Results')
                      : 'Check Answer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final total = widget.course.quizzes.length;
    final percentage = ((_correctCount / total) * 100).toInt();
    final isPassed = percentage >= 60;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: (isPassed
                              ? AppTheme.successGreen
                              : AppTheme.accentOrange)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPassed
                          ? Icons.emoji_events_rounded
                          : Icons.refresh_rounded,
                      size: 48,
                      color: isPassed
                          ? AppTheme.successGreen
                          : AppTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    isPassed ? 'Congratulations! \u{1F389}' : 'Keep Learning! \u{1F4AA}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPassed
                        ? 'You did a great job on this quiz!'
                        : 'Review the lessons and try again.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Score card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    decoration: AppTheme.softCard(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResultStat(
                          '$_correctCount/$total',
                          'Correct',
                          AppTheme.successGreen,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.divider,
                        ),
                        _buildResultStat(
                          '$percentage%',
                          'Score',
                          widget.course.color,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.course.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back to Course',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentQuestion = 0;
                          _selectedOption = null;
                          _showResult = false;
                          _correctCount = 0;
                          _quizFinished = false;
                          _animController.reset();
                          _animController.forward();
                        });
                      },
                      child: const Text(
                        'Retake Quiz',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Quit Quiz?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Your progress will be lost.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Quit',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
