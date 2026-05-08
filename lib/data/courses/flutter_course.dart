import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course flutterCourse = Course(
  id: 'dev_flutter_101',
  title: 'Flutter & Dart Bootcamp',
  description: 'Learn to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
  category: 'Development',
  icon: Icons.phone_android_rounded,
  color: const Color(0xFF02569B), // Flutter blue
  gradientEnd: const Color(0xFF0175C2),
  lessons: const [
    Lesson(
      id: 'f_l1',
      courseId: 'dev_flutter_101',
      title: 'Introduction to Dart',
      durationMinutes: 25,
      orderIndex: 0,
      youtubeVideoId: '1gDhl4leEzA', // Flutter in 100 Seconds
      content: 'Dart is the programming language used to build Flutter apps. It is an object-oriented, class-based, garbage-collected language with C-style syntax.\n\nKey Concepts:\n• Variables: var, final, const.\n• Data Types: int, double, String, bool, List, Map.\n• Functions: Reusable blocks of code.\nDart supports both Ahead-Of-Time (AOT) and Just-In-Time (JIT) compilation, making it fast for development and production.',
      quizzes: [
        Quiz(id: 'f_l1_q1', courseId: 'dev_flutter_101', question: 'Which programming language is used for Flutter development?', options: ['Java', 'Kotlin', 'Dart', 'Swift'], correctIndex: 2),
        Quiz(id: 'f_l1_q2', courseId: 'dev_flutter_101', question: 'Which keyword is used to declare a variable whose value cannot change once initialized?', options: ['var', 'dynamic', 'final', 'let'], correctIndex: 2),
        Quiz(id: 'f_l1_q3', courseId: 'dev_flutter_101', question: 'What type of language is Dart?', options: ['Functional', 'Object-Oriented', 'Procedural', 'Logic'], correctIndex: 1),
        Quiz(id: 'f_l1_q4', courseId: 'dev_flutter_101', question: 'Which compilation method helps Flutter achieve hot reload during development?', options: ['AOT', 'JIT', 'Interpreter', 'Bytecode'], correctIndex: 1),
        Quiz(id: 'f_l1_q5', courseId: 'dev_flutter_101', question: 'Which data type is used for whole numbers in Dart?', options: ['double', 'float', 'num', 'int'], correctIndex: 3),
      ],
    ),
    Lesson(
      id: 'f_l2',
      courseId: 'dev_flutter_101',
      title: 'Everything is a Widget',
      durationMinutes: 30,
      orderIndex: 1,
      content: 'In Flutter, almost everything is a widget. Widgets are the basic building blocks of a Flutter app\'s user interface.\n\nThere are two main types of widgets:\n1. StatelessWidget: A widget that does not require mutable state.\n2. StatefulWidget: A widget that has mutable state.\n\nCommon widgets include Text, Container, Row, Column, and Stack.',
      quizzes: [
        Quiz(id: 'f_l2_q1', courseId: 'dev_flutter_101', question: 'What is the basic building block of a Flutter UI?', options: ['Component', 'View', 'Widget', 'Element'], correctIndex: 2),
        Quiz(id: 'f_l2_q2', courseId: 'dev_flutter_101', question: 'Which widget should you use if your UI needs to change dynamically (e.g., when a user clicks a button)?', options: ['StatelessWidget', 'StatefulWidget', 'Container', 'Text'], correctIndex: 1),
        Quiz(id: 'f_l2_q3', courseId: 'dev_flutter_101', question: 'Which widget arranges its children in a horizontal line?', options: ['Column', 'Row', 'Stack', 'ListView'], correctIndex: 1),
        Quiz(id: 'f_l2_q4', courseId: 'dev_flutter_101', question: 'Which widget arranges its children vertically?', options: ['Row', 'Stack', 'Column', 'Grid'], correctIndex: 2),
        Quiz(id: 'f_l2_q5', courseId: 'dev_flutter_101', question: 'Which widget allows you to overlap its children?', options: ['Row', 'Column', 'Container', 'Stack'], correctIndex: 3),
      ],
    ),
    Lesson(
      id: 'f_l3',
      courseId: 'dev_flutter_101',
      title: 'State Management Basics',
      durationMinutes: 40,
      orderIndex: 2,
      content: 'State is data that can change over time and affects what the user sees on the screen.\n\nThe simplest way to manage state in Flutter is by using setState() within a StatefulWidget. When setState() is called, Flutter rebuilds the widget tree to reflect the new state.\n\nFor larger apps, developers use state management solutions like Provider, Riverpod, BLoC, or GetX.',
      quizzes: [
        Quiz(id: 'f_l3_q1', courseId: 'dev_flutter_101', question: 'What is state in Flutter?', options: ['A country', 'Data that changes over time', 'A static image', 'A type of widget'], correctIndex: 1),
        Quiz(id: 'f_l3_q2', courseId: 'dev_flutter_101', question: 'Which method is called to update the UI in a StatefulWidget?', options: ['updateUI()', 'refresh()', 'setState()', 'build()'], correctIndex: 2),
        Quiz(id: 'f_l3_q3', courseId: 'dev_flutter_101', question: 'What happens when setState() is called?', options: ['The app crashes', 'The app exits', 'The widget tree is rebuilt', 'Data is saved to database'], correctIndex: 2),
        Quiz(id: 'f_l3_q4', courseId: 'dev_flutter_101', question: 'Which of the following is a popular state management library for Flutter?', options: ['React', 'Provider', 'Django', 'Laravel'], correctIndex: 1),
        Quiz(id: 'f_l3_q5', courseId: 'dev_flutter_101', question: 'Where must setState() be used?', options: ['Inside a StatelessWidget', 'Inside a StatefulWidget', 'Inside main()', 'Inside pubspec.yaml'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'f_l4',
      courseId: 'dev_flutter_101',
      title: 'Navigation & Routing',
      durationMinutes: 35,
      orderIndex: 3,
      content: 'Most apps contain multiple screens (called routes in Flutter). Flutter provides a Navigator widget to manage a stack of routes.\n\n• Navigator.push(): Adds a new route to the stack (navigates to a new screen).\n• Navigator.pop(): Removes the current route from the stack (goes back).\n\nYou can use named routes for larger applications to manage navigation more efficiently.',
      quizzes: [
        Quiz(id: 'f_l4_q1', courseId: 'dev_flutter_101', question: 'What are screens called in Flutter?', options: ['Pages', 'Activities', 'Routes', 'Views'], correctIndex: 2),
        Quiz(id: 'f_l4_q2', courseId: 'dev_flutter_101', question: 'Which widget manages the stack of routes?', options: ['Stack', 'Navigator', 'Router', 'Scaffold'], correctIndex: 1),
        Quiz(id: 'f_l4_q3', courseId: 'dev_flutter_101', question: 'How do you navigate to a new screen?', options: ['Navigator.push()', 'Navigator.pop()', 'Navigator.next()', 'Navigator.go()'], correctIndex: 0),
        Quiz(id: 'f_l4_q4', courseId: 'dev_flutter_101', question: 'How do you return to the previous screen?', options: ['Navigator.back()', 'Navigator.pop()', 'Navigator.remove()', 'Navigator.exit()'], correctIndex: 1),
        Quiz(id: 'f_l4_q5', courseId: 'dev_flutter_101', question: 'For larger apps, what is the recommended way to handle navigation?', options: ['Pushing new widgets', 'Using named routes', 'Not navigating at all', 'Using external packages only'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'f_l5',
      courseId: 'dev_flutter_101',
      title: 'Networking & APIs',
      durationMinutes: 40,
      orderIndex: 4,
      content: 'Most modern apps fetch data from the internet via APIs. In Flutter, we commonly use the `http` package to make requests.\n\nDart handles asynchronous operations using `Future`, `async`, and `await`.\n\nExample:\nFuture<void> fetchData() async {\n  final response = await http.get(Uri.parse("url"));\n  // process response\n}',
      quizzes: [
        Quiz(id: 'f_l5_q1', courseId: 'dev_flutter_101', question: 'Which package is commonly used to make HTTP requests in Flutter?', options: ['url_launcher', 'http', 'async', 'fetch'], correctIndex: 1),
        Quiz(id: 'f_l5_q2', courseId: 'dev_flutter_101', question: 'Which keyword is used to declare a function as asynchronous?', options: ['await', 'Future', 'async', 'defer'], correctIndex: 2),
        Quiz(id: 'f_l5_q3', courseId: 'dev_flutter_101', question: 'What does the await keyword do?', options: ['Crashes the app', 'Pauses execution until the Future completes', 'Skips the function', 'Returns a boolean'], correctIndex: 1),
        Quiz(id: 'f_l5_q4', courseId: 'dev_flutter_101', question: 'What object represents a potential value or error that will be available at some time in the future?', options: ['Stream', 'Widget', 'State', 'Future'], correctIndex: 3),
        Quiz(id: 'f_l5_q5', courseId: 'dev_flutter_101', question: 'APIs typically return data in which format?', options: ['XML', 'HTML', 'JSON', 'CSS'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'f_l6',
      courseId: 'dev_flutter_101',
      title: 'Animations',
      durationMinutes: 30,
      orderIndex: 5,
      content: 'Animations make apps feel alive. Flutter has two main animation systems:\n\n1. Implicit Animations: Easy to use. Widgets like AnimatedContainer handle the animation automatically when their properties change.\n2. Explicit Animations: Requires an AnimationController. Gives you full control over the animation lifecycle (start, stop, reverse).',
      quizzes: [
        Quiz(id: 'f_l6_q1', courseId: 'dev_flutter_101', question: 'What is the purpose of animations in UI?', options: ['To confuse users', 'To make the app slower', 'To make the app feel alive and responsive', 'To increase file size'], correctIndex: 2),
        Quiz(id: 'f_l6_q2', courseId: 'dev_flutter_101', question: 'Which type of animation is easier to implement?', options: ['Explicit Animations', 'Implicit Animations', '3D Animations', 'Physics Animations'], correctIndex: 1),
        Quiz(id: 'f_l6_q3', courseId: 'dev_flutter_101', question: 'Which widget automatically animates changes to its properties (like color or size)?', options: ['Container', 'AnimatedContainer', 'Row', 'Column'], correctIndex: 1),
        Quiz(id: 'f_l6_q4', courseId: 'dev_flutter_101', question: 'What is required for Explicit Animations?', options: ['A state manager', 'An AnimationController', 'A database', 'An internet connection'], correctIndex: 1),
        Quiz(id: 'f_l6_q5', courseId: 'dev_flutter_101', question: 'If you need full control to start, stop, and reverse an animation, you should use...', options: ['Implicit animations', 'Explicit animations', 'No animations', 'Static images'], correctIndex: 1),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 'f_final_q1', courseId: 'dev_flutter_101', question: 'What language is Flutter written in?', options: ['Java', 'Dart', 'Swift', 'C++'], correctIndex: 1),
    Quiz(id: 'f_final_q2', courseId: 'dev_flutter_101', question: 'Which widget has mutable state?', options: ['StatelessWidget', 'Container', 'StatefulWidget', 'Text'], correctIndex: 2),
    Quiz(id: 'f_final_q3', courseId: 'dev_flutter_101', question: 'What command triggers a UI rebuild in a StatefulWidget?', options: ['build()', 'refresh()', 'setState()', 'update()'], correctIndex: 2),
    Quiz(id: 'f_final_q4', courseId: 'dev_flutter_101', question: 'Which keyword is used for asynchronous programming?', options: ['sync', 'await', 'FutureBuilder', 'Stream'], correctIndex: 1),
    Quiz(id: 'f_final_q5', courseId: 'dev_flutter_101', question: 'Which animation type requires an AnimationController?', options: ['Implicit', 'Explicit', 'Hero', 'Basic'], correctIndex: 1),
  ],
);
