// ─────────────────────────────────────────────────────────────────────────────
// LocalDataService — All app data stored locally via SharedPreferences.
// Firebase is used ONLY for Auth (login / register).
// This makes every button instant: no network, no hangs, no timeouts.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDataService {
  // ─── Singleton ─────────────────────────────────────────────────────────────
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  // ─── Keys ──────────────────────────────────────────────────────────────────
  static const _completedPrefix = 'completed_';
  static const _quizPrefix = 'quiz_';
  static const _enrolledKey = 'enrolled_courses';
  static const _certsKey = 'earned_certificates';
  static const _notePrefix = 'note_';

  // ─── Helpers ───────────────────────────────────────────────────────────────
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ══════════════════════════════════════════════════════════════════════════
  // LESSON PROGRESS
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<String>> getCompletedLessons(String courseId) async {
    final p = await _prefs;
    return p.getStringList('$_completedPrefix$courseId') ?? [];
  }

  Future<void> markLessonComplete(String courseId, String lessonId) async {
    final p = await _prefs;
    final key = '$_completedPrefix$courseId';
    final list = p.getStringList(key) ?? [];
    if (!list.contains(lessonId)) {
      list.add(lessonId);
      await p.setStringList(key, list);
    }
  }

  Future<void> markLessonIncomplete(String courseId, String lessonId) async {
    final p = await _prefs;
    final key = '$_completedPrefix$courseId';
    final list = p.getStringList(key) ?? [];
    list.remove(lessonId);
    await p.setStringList(key, list);
  }

  Future<double> getCourseProgress(String courseId, int totalLessons) async {
    if (totalLessons == 0) return 0.0;
    final completed = await getCompletedLessons(courseId);
    return completed.length / totalLessons;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ENROLLMENT
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<String>> getEnrolledCourseIds() async {
    final p = await _prefs;
    return p.getStringList(_enrolledKey) ?? [];
  }

  Future<bool> isEnrolled(String courseId) async {
    final ids = await getEnrolledCourseIds();
    return ids.contains(courseId);
  }

  Future<void> enrollCourse(String courseId) async {
    final p = await _prefs;
    final list = p.getStringList(_enrolledKey) ?? [];
    if (!list.contains(courseId)) {
      list.add(courseId);
      await p.setStringList(_enrolledKey, list);
    }
  }

  Future<void> unenrollCourse(String courseId) async {
    final p = await _prefs;
    final list = p.getStringList(_enrolledKey) ?? [];
    list.remove(courseId);
    await p.setStringList(_enrolledKey, list);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QUIZ SCORES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> saveQuizScore(String courseId, int score, int total) async {
    final p = await _prefs;
    await p.setString('$_quizPrefix$courseId',
        jsonEncode({'score': score, 'total': total}));
  }

  Future<Map<String, int>?> getQuizScore(String courseId) async {
    final p = await _prefs;
    final raw = p.getString('$_quizPrefix$courseId');
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {'score': map['score'] as int, 'total': map['total'] as int};
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OVERALL STATS
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getOverallStats(
    List<String> courseIds,
    Map<String, int> courseLessonCounts,
  ) async {
    int totalCompleted = 0;
    int totalLessons = 0;
    int totalQuizScore = 0;
    int totalQuizQuestions = 0;
    int quizzesTaken = 0;

    for (final id in courseIds) {
      final completed = await getCompletedLessons(id);
      totalCompleted += completed.length;
      totalLessons += courseLessonCounts[id] ?? 0;

      final quiz = await getQuizScore(id);
      if (quiz != null) {
        totalQuizScore += quiz['score']!;
        totalQuizQuestions += quiz['total']!;
        quizzesTaken++;
      }
    }

    return {
      'lessonsCompleted': totalCompleted,
      'totalLessons': totalLessons,
      'quizzesTaken': quizzesTaken,
      'totalQuizScore': totalQuizScore,
      'totalQuizQuestions': totalQuizQuestions,
      'overallProgress':
          totalLessons > 0 ? totalCompleted / totalLessons : 0.0,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CERTIFICATES
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getEarnedCertificates() async {
    final p = await _prefs;
    final raw = p.getStringList(_certsKey) ?? [];
    return raw.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  Future<bool> hasCertificate(String courseId) async {
    final certs = await getEarnedCertificates();
    return certs.any((c) => c['courseId'] == courseId);
  }

  Future<void> awardCertificate(String courseId, String courseTitle) async {
    final p = await _prefs;
    final raw = p.getStringList(_certsKey) ?? [];
    // Don't duplicate
    final existing = raw
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .where((c) => c['courseId'] == courseId)
        .toList();
    if (existing.isNotEmpty) return;

    raw.add(jsonEncode({
      'courseId': courseId,
      'courseTitle': courseTitle,
      'earnedAt': DateTime.now().toIso8601String(),
    }));
    await p.setStringList(_certsKey, raw);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> saveNote(String lessonId, String note) async {
    final p = await _prefs;
    await p.setString('$_notePrefix$lessonId', note);
  }

  Future<String?> getNote(String lessonId) async {
    final p = await _prefs;
    return p.getString('$_notePrefix$lessonId');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESET
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> resetAllProgress() async {
    final p = await _prefs;
    final keys = p.getKeys()
        .where((k) =>
            k.startsWith(_completedPrefix) ||
            k.startsWith(_quizPrefix) ||
            k.startsWith(_notePrefix) ||
            k == _enrolledKey ||
            k == _certsKey)
        .toList();
    for (final k in keys) {
      await p.remove(k);
    }
  }
}
