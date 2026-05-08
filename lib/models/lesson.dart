import 'quiz.dart';

class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final int durationMinutes;
  final int orderIndex;
  final List<Quiz>? quizzes;
  final String? youtubeVideoId;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.durationMinutes,
    required this.orderIndex,
    this.quizzes,
    this.youtubeVideoId,
  });
}
