import 'package:flutter/material.dart';
import 'lesson.dart';
import 'quiz.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  final List<Lesson> lessons;
  final List<Quiz> quizzes;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.gradientEnd,
    required this.lessons,
    required this.quizzes,
  });

  int get totalLessons => lessons.length;
  int get totalQuizzes => quizzes.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': {'codePoint': icon.codePoint, 'fontFamily': icon.fontFamily},
      // ignore: deprecated_member_use
      'color': color.value,
      // ignore: deprecated_member_use
      'gradientEnd': gradientEnd.value,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'quizzes': quizzes.map((q) => q.toMap()).toList(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    final iconMap = map['icon'] as Map<String, dynamic>?;
    final iconData = iconMap != null
        ? IconData(
            iconMap['codePoint'] as int,
            fontFamily: iconMap['fontFamily'] as String?,
          )
        : Icons.school_rounded;

    return Course(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      icon: iconData,
      color: Color(map['color'] as int? ?? 0xFF02569B),
      gradientEnd: Color(map['gradientEnd'] as int? ?? 0xFF0175C2),
      lessons: map['lessons'] != null
          ? List<Lesson>.from(
              (map['lessons'] as List).map((l) => Lesson.fromMap(l)),
            )
          : [],
      quizzes: map['quizzes'] != null
          ? List<Quiz>.from(
              (map['quizzes'] as List).map((q) => Quiz.fromMap(q)),
            )
          : [],
    );
  }
}
