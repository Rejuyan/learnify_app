import 'package:flutter/foundation.dart';
import 'courses/flutter_course.dart';
import 'courses/python_course.dart';
import 'courses/communication_course.dart';
import 'courses/teaching_course.dart';
import 'courses/basic_computing_course.dart';
import 'courses/design_course.dart';
import 'courses/marketing_course.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';

List<Course> sampleCourses = [
  flutterCourse,
  pythonCourse,
  communicationCourse,
  teachingCourse,
  basicComputingCourse,
  designCourse,
  marketingCourse,
];

List<String> get allCategories {
  return sampleCourses.map((c) => c.category).toSet().toList()..sort();
}

Future<void> updateCoursesFromFirestore() async {
  try {
    final live = await FirestoreService().fetchLiveCoursesFromFirestore();
    if (live.isNotEmpty) {
      sampleCourses = live;
    }
  } catch (e) {
    debugPrint("Failed to fetch live courses from Firestore: $e");
  }
}
