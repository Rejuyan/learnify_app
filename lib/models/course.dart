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
}
