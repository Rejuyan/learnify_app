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
  final String? pdfUrl;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.durationMinutes,
    required this.orderIndex,
    this.quizzes,
    this.youtubeVideoId,
    this.pdfUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'durationMinutes': durationMinutes,
      'orderIndex': orderIndex,
      'quizzes': quizzes?.map((q) => q.toMap()).toList(),
      'youtubeVideoId': youtubeVideoId,
      'pdfUrl': pdfUrl,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      orderIndex: map['orderIndex'] as int? ?? 0,
      quizzes: map['quizzes'] != null
          ? List<Quiz>.from((map['quizzes'] as List).map((q) => Quiz.fromMap(q)))
          : null,
      youtubeVideoId: map['youtubeVideoId'] as String?,
      pdfUrl: map['pdfUrl'] as String?,
    );
  }
}
