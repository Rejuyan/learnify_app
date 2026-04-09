// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class CourseEditScreen extends StatefulWidget {
  final Course? course;

  const CourseEditScreen({super.key, this.course});

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirestoreService();

  late bool _isEditMode;
  late TextEditingController _idController;
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;

  late List<Lesson> _lessons;
  late List<Quiz> _courseQuizzes;

  int _selectedThemeIndex = 0;
  int _selectedIconIndex = 0;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _presetThemes = [
    {'name': 'Teal/Cyan', 'color': const Color(0xFF00BFA5), 'gradient': const Color(0xFF00E5FF)},
    {'name': 'Blue/Flutter', 'color': const Color(0xFF02569B), 'gradient': const Color(0xFF0175C2)},
    {'name': 'Purple/Indigo', 'color': const Color(0xFF6C63FF), 'gradient': const Color(0xFF4A3AFF)},
    {'name': 'Pink/Red', 'color': const Color(0xFFF06292), 'gradient': const Color(0xFFE91E63)},
    {'name': 'Amber/Orange', 'color': const Color(0xFFFFB74D), 'gradient': const Color(0xFFFF9800)},
    {'name': 'Green/Lime', 'color': const Color(0xFF81C784), 'gradient': const Color(0xFF4CAF50)},
    {'name': 'Deep Purple', 'color': const Color(0xFF7C4DFF), 'gradient': const Color(0xFF3F51B5)},
  ];

  final List<Map<String, dynamic>> _presetIcons = [
    {'name': 'School / Academics', 'icon': Icons.school_rounded},
    {'name': 'Computer / Tech', 'icon': Icons.computer_rounded},
    {'name': 'Book / Reading', 'icon': Icons.menu_book_rounded},
    {'name': 'Brush / Design', 'icon': Icons.brush_rounded},
    {'name': 'Code / Dev', 'icon': Icons.code_rounded},
    {'name': 'Business / Finance', 'icon': Icons.monetization_on_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.course != null;
    
    _idController = TextEditingController(text: widget.course?.id ?? '');
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _categoryController = TextEditingController(text: widget.course?.category ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');

    _lessons = widget.course != null ? List<Lesson>.from(widget.course!.lessons) : [];
    _courseQuizzes = widget.course != null ? List<Quiz>.from(widget.course!.quizzes) : [];

    // Resolve active color index
    if (widget.course != null) {
      for (int i = 0; i < _presetThemes.length; i++) {
        if (_presetThemes[i]['color'].value == widget.course!.color.value) {
          _selectedThemeIndex = i;
          break;
        }
      }

      for (int i = 0; i < _presetIcons.length; i++) {
        if (_presetIcons[i]['icon'].codePoint == widget.course!.icon.codePoint) {
          _selectedIconIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final String courseId = _idController.text.trim().toLowerCase().replaceAll(' ', '_');
    final activeTheme = _presetThemes[_selectedThemeIndex];
    final activeIcon = _presetIcons[_selectedIconIndex]['icon'] as IconData;

    final updatedCourse = Course(
      id: courseId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
      icon: activeIcon,
      color: activeTheme['color'] as Color,
      gradientEnd: activeTheme['gradient'] as Color,
      lessons: _lessons,
      quizzes: _courseQuizzes,
    );

    try {
      await _fs.saveCourse(updatedCourse);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course saved successfully!'), backgroundColor: AppTheme.successGreen),
        );
        Navigator.pop(context, true); // pop with refresh parameter
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCourse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162E),
        title: const Text('Delete Course', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this course? All lessons and quizzes will be lost permanently.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white24)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      await _fs.deleteCourse(widget.course!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted.'), backgroundColor: AppTheme.successGreen),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showLessonDialog({Lesson? lesson, int? index}) {
    final titleCtrl = TextEditingController(text: lesson?.title ?? '');
    final durationCtrl = TextEditingController(text: lesson?.durationMinutes.toString() ?? '15');
    final contentCtrl = TextEditingController(text: lesson?.content ?? '');
    final youtubeCtrl = TextEditingController(text: lesson?.youtubeVideoId ?? '');
    final pdfCtrl = TextEditingController(text: lesson?.pdfUrl ?? '');
    final lessonFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16162E),
          title: Text(lesson == null ? 'Add Lesson' : 'Edit Lesson', style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: lessonFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Lesson Title', labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: durationCtrl,
                      decoration: const InputDecoration(labelText: 'Duration (Minutes)', labelStyle: TextStyle(color: Colors.white70)),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid number' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: contentCtrl,
                      decoration: const InputDecoration(labelText: 'Content/Syllabus Notes', labelStyle: TextStyle(color: Colors.white70)),
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: youtubeCtrl,
                      decoration: const InputDecoration(labelText: 'YouTube Video ID (Optional)', labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pdfCtrl,
                      decoration: const InputDecoration(labelText: 'PDF URL / Slide URL (Optional)', labelStyle: TextStyle(color: Colors.white70)),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white24)),
            ),
            ElevatedButton(
              onPressed: () {
                if (!lessonFormKey.currentState!.validate()) return;
                
                final String courseId = _idController.text.trim().toLowerCase().replaceAll(' ', '_');
                final finalLessons = List<Lesson>.from(_lessons);

                final newLesson = Lesson(
                  id: lesson?.id ?? '${courseId}_l${finalLessons.length + 1}',
                  courseId: courseId,
                  title: titleCtrl.text.trim(),
                  durationMinutes: int.parse(durationCtrl.text),
                  content: contentCtrl.text.trim(),
                  orderIndex: lesson?.orderIndex ?? finalLessons.length,
                  youtubeVideoId: youtubeCtrl.text.trim().isEmpty ? null : youtubeCtrl.text.trim(),
                  pdfUrl: pdfCtrl.text.trim().isEmpty ? null : pdfCtrl.text.trim(),
                  quizzes: lesson?.quizzes,
                );

                setState(() {
                  if (index != null) {
                    _lessons[index] = newLesson;
                  } else {
                    _lessons.add(newLesson);
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  void _showQuizDialog({required List<Quiz> quizzes, Quiz? quiz, int? index, required Function(List<Quiz>) onSaved}) {
    final questionCtrl = TextEditingController(text: quiz?.question ?? '');
    final opt1Ctrl = TextEditingController(text: quiz != null && quiz.options.isNotEmpty ? quiz.options[0] : '');
    final opt2Ctrl = TextEditingController(text: quiz != null && quiz.options.length > 1 ? quiz.options[1] : '');
    final opt3Ctrl = TextEditingController(text: quiz != null && quiz.options.length > 2 ? quiz.options[2] : '');
    final opt4Ctrl = TextEditingController(text: quiz != null && quiz.options.length > 3 ? quiz.options[3] : '');
    int correctIdx = quiz?.correctIndex ?? 0;
    final quizFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16162E),
              title: Text(quiz == null ? 'Add Quiz Question' : 'Edit Quiz Question', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: quizFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: questionCtrl,
                          decoration: const InputDecoration(labelText: 'Question Text', labelStyle: TextStyle(color: Colors.white70)),
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => v == null || v.isEmpty ? 'Question is required' : null,
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Options (Select radio for correct answer):',
                            style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDialogOptionRow(0, opt1Ctrl, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                        _buildDialogOptionRow(1, opt2Ctrl, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                        _buildDialogOptionRow(2, opt3Ctrl, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                        _buildDialogOptionRow(3, opt4Ctrl, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white24)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!quizFormKey.currentState!.validate()) return;
                    
                    final options = [
                      opt1Ctrl.text.trim(),
                      opt2Ctrl.text.trim(),
                      opt3Ctrl.text.trim(),
                      opt4Ctrl.text.trim(),
                    ].where((opt) => opt.isNotEmpty).toList();

                    if (options.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('At least 2 options are required.')),
                      );
                      return;
                    }

                    final String courseId = _idController.text.trim().toLowerCase().replaceAll(' ', '_');
                    final updatedQuizzesList = List<Quiz>.from(quizzes);

                    final newQuiz = Quiz(
                      id: quiz?.id ?? '${courseId}_q${updatedQuizzesList.length + 1}',
                      courseId: courseId,
                      question: questionCtrl.text.trim(),
                      options: options,
                      correctIndex: correctIdx,
                    );

                    if (index != null) {
                      updatedQuizzesList[index] = newQuiz;
                    } else {
                      updatedQuizzesList.add(newQuiz);
                    }

                    onSaved(updatedQuizzesList);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogOptionRow(int index, TextEditingController controller, int correctIdx, Function(int) onSelected) {
    return Row(
      children: [
        Radio<int>(
          value: index,
          groupValue: correctIdx,
          activeColor: AppTheme.successGreen,
          onChanged: (v) => onSelected(v!),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Option ${index + 1}',
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
            validator: (v) => index < 2 && (v == null || v.isEmpty) ? 'Option ${index + 1} is required' : null,
          ),
        ),
      ],
    );
  }

  void _manageLessonQuizzes(int lessonIndex) {
    final lesson = _lessons[lessonIndex];
    final lessonQuizzes = List<Quiz>.from(lesson.quizzes ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'LESSON QUIZZES',
                                  style: TextStyle(color: AppTheme.courseTeal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lesson.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.courseTeal.withValues(alpha: 0.15), foregroundColor: AppTheme.courseTeal),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Quiz'),
                            onPressed: () {
                              _showQuizDialog(
                                quizzes: lessonQuizzes,
                                onSaved: (updated) {
                                  setModalState(() => lessonQuizzes.clear());
                                  setModalState(() => lessonQuizzes.addAll(updated));
                                  setState(() {
                                    _lessons[lessonIndex] = Lesson(
                                      id: lesson.id,
                                      courseId: lesson.courseId,
                                      title: lesson.title,
                                      content: lesson.content,
                                      durationMinutes: lesson.durationMinutes,
                                      orderIndex: lesson.orderIndex,
                                      youtubeVideoId: lesson.youtubeVideoId,
                                      pdfUrl: lesson.pdfUrl,
                                      quizzes: lessonQuizzes,
                                    );
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      Expanded(
                        child: lessonQuizzes.isEmpty
                            ? const Center(
                                child: Text('No quizzes for this lesson yet.', style: TextStyle(color: Colors.white38)),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: lessonQuizzes.length,
                                itemBuilder: (context, qIdx) {
                                  final quiz = lessonQuizzes[qIdx];
                                  return Card(
                                    color: const Color(0xFF16162E),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      title: Text(quiz.question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Wrap(
                                          spacing: 8, runSpacing: 8,
                                          children: quiz.options.asMap().entries.map((entry) {
                                            final isCorrect = entry.key == quiz.correctIndex;
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isCorrect ? AppTheme.successGreen.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                                                border: Border.all(color: isCorrect ? AppTheme.successGreen : Colors.white10),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                entry.value,
                                                style: TextStyle(color: isCorrect ? AppTheme.successGreen : Colors.white70, fontSize: 10),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded, color: Colors.white30, size: 18),
                                            onPressed: () {
                                              _showQuizDialog(
                                                quizzes: lessonQuizzes,
                                                quiz: quiz,
                                                index: qIdx,
                                                onSaved: (updated) {
                                                  setModalState(() => lessonQuizzes.clear());
                                                  setModalState(() => lessonQuizzes.addAll(updated));
                                                  setState(() {
                                                    _lessons[lessonIndex] = Lesson(
                                                      id: lesson.id,
                                                      courseId: lesson.courseId,
                                                      title: lesson.title,
                                                      content: lesson.content,
                                                      durationMinutes: lesson.durationMinutes,
                                                      orderIndex: lesson.orderIndex,
                                                      youtubeVideoId: lesson.youtubeVideoId,
                                                      pdfUrl: lesson.pdfUrl,
                                                      quizzes: lessonQuizzes,
                                                    );
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorRed, size: 18),
                                            onPressed: () {
                                              setModalState(() {
                                                lessonQuizzes.removeAt(qIdx);
                                              });
                                              setState(() {
                                                _lessons[lessonIndex] = Lesson(
                                                  id: lesson.id,
                                                  courseId: lesson.courseId,
                                                  title: lesson.title,
                                                  content: lesson.content,
                                                  durationMinutes: lesson.durationMinutes,
                                                  orderIndex: lesson.orderIndex,
                                                  youtubeVideoId: lesson.youtubeVideoId,
                                                  pdfUrl: lesson.pdfUrl,
                                                  quizzes: lessonQuizzes,
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _presetThemes[_presetThemes.length > _selectedThemeIndex ? _selectedThemeIndex : 0];
    final activeColor = activeTheme['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditMode ? 'EDIT COURSE' : 'CREATE COURSE',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorRed),
              onPressed: _isSaving ? null : _deleteCourse,
              tooltip: 'Delete Course',
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Course Metadata Card ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16162E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('COURSE METADATA', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _idController,
                            decoration: const InputDecoration(
                              labelText: 'Course unique ID (e.g. math_basics)',
                              labelStyle: TextStyle(color: Colors.white54),
                            ),
                            style: const TextStyle(color: Colors.white),
                            enabled: !_isEditMode,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Course unique ID is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Course Title',
                              labelStyle: TextStyle(color: Colors.white54),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: Colors.white54),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              labelStyle: TextStyle(color: Colors.white54),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Styling Presets ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16162E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('THEME COLOR PALETTE', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 48,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _presetThemes.length,
                              itemBuilder: (context, index) {
                                final theme = _presetThemes[index];
                                final bool isSelected = _selectedThemeIndex == index;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedThemeIndex = index),
                                  child: Container(
                                    width: 44, height: 44,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [theme['color'] as Color, theme['gradient'] as Color],
                                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: isSelected
                                          ? [BoxShadow(color: (theme['color'] as Color).withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)]
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('COURSE ICON STYLE', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12, runSpacing: 12,
                            children: _presetIcons.asMap().entries.map((entry) {
                              final int idx = entry.key;
                              final iconObj = entry.value;
                              final bool isSelected = _selectedIconIndex == idx;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedIconIndex = idx),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? activeColor.withValues(alpha: 0.15) : const Color(0xFF0D0D2B),
                                    border: Border.all(
                                      color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    iconObj['icon'] as IconData,
                                    color: isSelected ? activeColor : Colors.white60,
                                    size: 20,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Lessons Manager ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SYLLABUS & LESSONS (${_lessons.length})',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor.withValues(alpha: 0.1),
                            foregroundColor: activeColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Lecture'),
                          onPressed: () => _showLessonDialog(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _lessons.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16162E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                            ),
                            child: const Center(
                              child: Text('No lectures created yet. Add lectures to compile the course.', style: TextStyle(color: Colors.white38, fontSize: 13)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _lessons.length,
                            itemBuilder: (context, idx) {
                              final lesson = _lessons[idx];
                              return Card(
                                color: const Color(0xFF16162E),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                borderOnForeground: false,
                                child: ListTile(
                                  leading: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${idx + 1}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  title: Text(lesson.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(
                                    '${lesson.durationMinutes} mins • ${(lesson.quizzes?.length ?? 0)} quizzes',
                                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.help_outline_rounded, color: AppTheme.courseTeal, size: 20),
                                        onPressed: () => _manageLessonQuizzes(idx),
                                        tooltip: 'Manage Quizzes',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: Colors.white30, size: 20),
                                        onPressed: () => _showLessonDialog(lesson: lesson, index: idx),
                                        tooltip: 'Edit Lesson',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _lessons.removeAt(idx);
                                            // Reindex orderIndex
                                            for (int i = 0; i < _lessons.length; i++) {
                                              _lessons[i] = Lesson(
                                                id: _lessons[i].id,
                                                courseId: _lessons[i].courseId,
                                                title: _lessons[i].title,
                                                content: _lessons[i].content,
                                                durationMinutes: _lessons[i].durationMinutes,
                                                orderIndex: i,
                                                youtubeVideoId: _lessons[i].youtubeVideoId,
                                                pdfUrl: _lessons[i].pdfUrl,
                                                quizzes: _lessons[i].quizzes,
                                              );
                                            }
                                          });
                                        },
                                        tooltip: 'Delete Lesson',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 32),

                    // --- Course-Level Quizzes Manager ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COURSE FINAL QUIZ (${_courseQuizzes.length})',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor.withValues(alpha: 0.1),
                            foregroundColor: activeColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Question'),
                          onPressed: () {
                            _showQuizDialog(
                              quizzes: _courseQuizzes,
                              onSaved: (updated) {
                                setState(() {
                                  _courseQuizzes = updated;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _courseQuizzes.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16162E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                            ),
                            child: const Center(
                              child: Text('No final quiz questions created yet.', style: TextStyle(color: Colors.white38, fontSize: 13)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _courseQuizzes.length,
                            itemBuilder: (context, idx) {
                              final quiz = _courseQuizzes[idx];
                              return Card(
                                color: const Color(0xFF16162E),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                borderOnForeground: false,
                                child: ListTile(
                                  leading: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${idx + 1}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  title: Text(quiz.question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Wrap(
                                      spacing: 8, runSpacing: 8,
                                      children: quiz.options.asMap().entries.map((entry) {
                                        final isCorrect = entry.key == quiz.correctIndex;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isCorrect ? AppTheme.successGreen.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                                            border: Border.all(color: isCorrect ? AppTheme.successGreen : Colors.white10),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            entry.value,
                                            style: TextStyle(color: isCorrect ? AppTheme.successGreen : Colors.white70, fontSize: 10),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: Colors.white30, size: 20),
                                        onPressed: () {
                                          _showQuizDialog(
                                            quizzes: _courseQuizzes,
                                            quiz: quiz,
                                            index: idx,
                                            onSaved: (updated) {
                                              setState(() {
                                                _courseQuizzes = updated;
                                              });
                                            },
                                          );
                                        },
                                        tooltip: 'Edit Quiz Question',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _courseQuizzes.removeAt(idx);
                                          });
                                        },
                                        tooltip: 'Delete Quiz Question',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 48),

                    // --- Save Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text('Save Entire Course Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: _saveCourse,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
