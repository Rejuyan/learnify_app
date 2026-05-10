import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => AuthService().currentUser?.uid;

  bool get isLoggedIn => _uid != null;

  // ─── User Document ──────────────────────────────────────────────
  DocumentReference<Map<String, dynamic>>? get _userDoc =>
      _uid != null ? _db.collection('users').doc(_uid) : null;

  Future<void> initUserDocument({List<String>? migrateCourseIds}) async {
    if (_userDoc == null) return;
    final snap = await _userDoc!.get();
    if (!snap.exists) {
      await _userDoc!.set({
        'email': AuthService().currentUser?.email ?? '',
        'displayName': AuthService().currentUser?.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'enrolledCourses': [],
        'earnedCertificates': [],
      });
      // New user? Migrate any local progress they had as a guest
      if (migrateCourseIds != null) {
        await migrateLocalProgress(migrateCourseIds);
      }
    }
  }

  Future<void> migrateLocalProgress(List<String> courseIds) async {
    if (_userDoc == null) return;
    
    for (final courseId in courseIds) {
      final localCompleted = await ProgressService.getCompletedLessons(courseId);
      if (localCompleted.isNotEmpty) {
        await markLessonsComplete(courseId, localCompleted);
      }
      
      final localQuiz = await ProgressService.getQuizScore(courseId);
      if (localQuiz != null) {
        await saveQuizScore(courseId, localQuiz['score']!, localQuiz['total']!);
      }
      
      final isEnrolledLocal = await ProgressService.isEnrolled(courseId);
      if (isEnrolledLocal) {
        await enrollCourse(courseId);
      }
    }
  }

  Future<void> markLessonsComplete(String courseId, List<String> lessonIds) async {
    if (_userDoc == null) return;
    await _userDoc!
        .collection('progress')
        .doc(courseId)
        .set({
      'completedLessons': FieldValue.arrayUnion(lessonIds),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile({String? name}) async {

  Future<void> updateUserProfile({String? name}) async {
    if (_userDoc == null) return;
    final Map<String, dynamic> updates = {};
    if (name != null) updates['displayName'] = name;
    if (updates.isNotEmpty) {
      await _userDoc!.update(updates);
    }
  }

  // ─── Progress ────────────────────────────────────────────────────

  Future<void> markLessonComplete(String courseId, String lessonId) async {
    if (_userDoc == null) return;
    await _userDoc!
        .collection('progress')
        .doc(courseId)
        .set({
      'completedLessons': FieldValue.arrayUnion([lessonId]),
    }, SetOptions(merge: true));
  }

  Future<void> markLessonIncomplete(String courseId, String lessonId) async {
    if (_userDoc == null) return;
    await _userDoc!
        .collection('progress')
        .doc(courseId)
        .set({
      'completedLessons': FieldValue.arrayRemove([lessonId]),
    }, SetOptions(merge: true));
  }

  Future<List<String>> getCompletedLessons(String courseId) async {
    if (_userDoc == null) return [];
    final snap = await _userDoc!.collection('progress').doc(courseId).get();
    if (!snap.exists) return [];
    final data = snap.data();
    return List<String>.from(data?['completedLessons'] ?? []);
  }

  Future<double> getCourseProgress(String courseId, int totalLessons) async {
    if (totalLessons == 0) return 0.0;
    final completed = await getCompletedLessons(courseId);
    return completed.length / totalLessons;
  }

  // ─── Quiz Scores ─────────────────────────────────────────────────

  Future<void> saveQuizScore(String courseId, int score, int total) async {
    if (_userDoc == null) return;
    await _userDoc!
        .collection('progress')
        .doc(courseId)
        .set({
      'quizScore': score,
      'quizTotal': total,
      'quizTaken': true,
    }, SetOptions(merge: true));
  }

  Future<Map<String, int>?> getQuizScore(String courseId) async {
    if (_userDoc == null) return null;
    final snap = await _userDoc!.collection('progress').doc(courseId).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data?['quizTaken'] != true) return null;
    return {
      'score': data?['quizScore'] ?? 0,
      'total': data?['quizTotal'] ?? 0,
    };
  }

  // ─── Overall Stats ───────────────────────────────────────────────

  Future<Map<String, dynamic>> getOverallStats(
    List<String> courseIds,
    Map<String, int> courseLessonCounts,
  ) async {
    int totalLessonsCompleted = 0;
    int totalLessons = 0;
    int totalQuizScore = 0;
    int quizzesTaken = 0;

    for (final courseId in courseIds) {
      final completed = await getCompletedLessons(courseId);
      totalLessonsCompleted += completed.length;
      totalLessons += courseLessonCounts[courseId] ?? 0;
      final quizScore = await getQuizScore(courseId);
      if (quizScore != null) {
        totalQuizScore += quizScore['score']!;
        quizzesTaken++;
      }
    }

    return {
      'lessonsCompleted': totalLessonsCompleted,
      'totalLessons': totalLessons,
      'quizzesTaken': quizzesTaken,
      'totalQuizScore': totalQuizScore,
      'overallProgress':
          totalLessons > 0 ? totalLessonsCompleted / totalLessons : 0.0,
    };
  }

  // ─── Enrollment / Bookmarks ──────────────────────────────────────

  Future<void> enrollCourse(String courseId) async {
    if (_userDoc == null) return;
    await _userDoc!.set({
      'enrolledCourses': FieldValue.arrayUnion([courseId]),
    }, SetOptions(merge: true));
  }

  Future<void> unenrollCourse(String courseId) async {
    if (_userDoc == null) return;
    await _userDoc!.set({
      'enrolledCourses': FieldValue.arrayRemove([courseId]),
    }, SetOptions(merge: true));
  }

  Future<List<String>> getEnrolledCourseIds() async {
    if (_userDoc == null) return [];
    final snap = await _userDoc!.get();
    if (!snap.exists) return [];
    return List<String>.from(snap.data()?['enrolledCourses'] ?? []);
  }

  Future<bool> isEnrolled(String courseId) async {
    final enrolled = await getEnrolledCourseIds();
    return enrolled.contains(courseId);
  }

  // ─── Certificates ────────────────────────────────────────────────

  Future<void> awardCertificate(String courseId, String courseTitle) async {
    if (_userDoc == null) return;
    await _userDoc!.set({
      'earnedCertificates': FieldValue.arrayUnion([
        {
          'courseId': courseId,
          'courseTitle': courseTitle,
          'earnedAt': DateTime.now().toIso8601String(),
        }
      ]),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getEarnedCertificates() async {
    if (_userDoc == null) return [];
    final snap = await _userDoc!.get();
    if (!snap.exists) return [];
    final certs = snap.data()?['earnedCertificates'];
    if (certs == null) return [];
    return List<Map<String, dynamic>>.from(certs);
  }

  Future<bool> hasCertificate(String courseId) async {
    final certs = await getEarnedCertificates();
    return certs.any((c) => c['courseId'] == courseId);
  }

  // ─── Notes ───────────────────────────────────────────────────────

  Future<void> saveNote(String lessonId, String note) async {
    if (_userDoc == null) return;
    await _userDoc!
        .collection('notes')
        .doc(lessonId)
        .set({'content': note, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<String?> getNote(String lessonId) async {
    if (_userDoc == null) return null;
    final snap = await _userDoc!.collection('notes').doc(lessonId).get();
    if (!snap.exists) return null;
    return snap.data()?['content'] as String?;
  }
}
