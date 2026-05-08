import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _completedLessonsPrefix = 'completed_lessons_';
  static const String _quizScorePrefix = 'quiz_score_';
  static const String _quizTakenPrefix = 'quiz_taken_';

  // ─── Lesson Progress ────────────────────────────────────────────

  static Future<void> markLessonComplete(String courseId, String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completedLessonsPrefix$courseId';
    final completed = prefs.getStringList(key) ?? [];
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
      await prefs.setStringList(key, completed);
    }
  }

  static Future<void> markLessonIncomplete(String courseId, String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completedLessonsPrefix$courseId';
    final completed = prefs.getStringList(key) ?? [];
    completed.remove(lessonId);
    await prefs.setStringList(key, completed);
  }

  static Future<List<String>> getCompletedLessons(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_completedLessonsPrefix$courseId') ?? [];
  }

  static Future<bool> isLessonComplete(String courseId, String lessonId) async {
    final completed = await getCompletedLessons(courseId);
    return completed.contains(lessonId);
  }

  static Future<double> getCourseProgress(String courseId, int totalLessons) async {
    if (totalLessons == 0) return 0.0;
    final completed = await getCompletedLessons(courseId);
    return completed.length / totalLessons;
  }

  // ─── Quiz Scores ────────────────────────────────────────────────

  static Future<void> saveQuizScore(String courseId, int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_quizScorePrefix${courseId}_score', score);
    await prefs.setInt('$_quizScorePrefix${courseId}_total', total);
    await prefs.setBool('$_quizTakenPrefix$courseId', true);
  }

  static Future<Map<String, int>?> getQuizScore(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final taken = prefs.getBool('$_quizTakenPrefix$courseId') ?? false;
    if (!taken) return null;
    final score = prefs.getInt('$_quizScorePrefix${courseId}_score') ?? 0;
    final total = prefs.getInt('$_quizScorePrefix${courseId}_total') ?? 0;
    return {'score': score, 'total': total};
  }

  static Future<bool> hasQuizBeenTaken(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_quizTakenPrefix$courseId') ?? false;
  }

  // ─── Overall Stats ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> getOverallStats(
    List<String> courseIds,
    Map<String, int> courseLessonCounts,
  ) async {
    int totalLessonsCompleted = 0;
    int totalLessons = 0;
    int totalQuizScore = 0;
    int totalQuizQuestions = 0;
    int quizzesTaken = 0;

    for (final courseId in courseIds) {
      final completed = await getCompletedLessons(courseId);
      totalLessonsCompleted += completed.length;
      totalLessons += courseLessonCounts[courseId] ?? 0;

      final quizScore = await getQuizScore(courseId);
      if (quizScore != null) {
        totalQuizScore += quizScore['score']!;
        totalQuizQuestions += quizScore['total']!;
        quizzesTaken++;
      }
    }

    return {
      'lessonsCompleted': totalLessonsCompleted,
      'totalLessons': totalLessons,
      'quizzesTaken': quizzesTaken,
      'totalQuizScore': totalQuizScore,
      'totalQuizQuestions': totalQuizQuestions,
      'overallProgress': totalLessons > 0 ? totalLessonsCompleted / totalLessons : 0.0,
    };
  }

  // ─── Reset ──────────────────────────────────────────────────────

  static Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
