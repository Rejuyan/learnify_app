import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course teachingCourse = Course(
  id: 'ta_teach_101',
  title: 'Effective Online Teaching',
  description: 'Learn the pedagogy and tools required to engage students and deliver impactful lessons in a virtual environment.',
  category: 'Teaching & Academics',
  icon: Icons.school_rounded,
  color: const Color(0xFFFF9800), // Orange
  gradientEnd: const Color(0xFFF57C00),
  lessons: const [
    Lesson(
      id: 't_l1',
      courseId: 'ta_teach_101',
      title: 'Principles of Instructional Design',
      durationMinutes: 25,
      orderIndex: 0,
      content: 'Instructional design is the practice of creating instructional experiences that make the acquisition of knowledge more efficient, effective, and appealing.\n\nThe ADDIE model is a common framework:\n• Analyze: Understand the learners.\n• Design: Outline the objectives.\n• Develop: Create the content.\n• Implement: Deliver the course.\n• Evaluate: Measure effectiveness.',
      quizzes: [
        Quiz(id: 't_l1_q1', courseId: 'ta_teach_101', question: 'What does the "A" in the ADDIE model stand for?', options: ['Apply', 'Analyze', 'Assess', 'Articulate'], correctIndex: 1),
        Quiz(id: 't_l1_q2', courseId: 'ta_teach_101', question: 'What is the goal of instructional design?', options: ['To make learning harder', 'To make learning efficient and effective', 'To sell books', 'To entertain'], correctIndex: 1),
        Quiz(id: 't_l1_q3', courseId: 'ta_teach_101', question: 'In which phase of ADDIE do you create the actual content?', options: ['Design', 'Evaluate', 'Develop', 'Analyze'], correctIndex: 2),
        Quiz(id: 't_l1_q4', courseId: 'ta_teach_101', question: 'What do you do during the "Evaluate" phase?', options: ['Write code', 'Measure effectiveness of the course', 'Teach the students', 'Design the syllabus'], correctIndex: 1),
        Quiz(id: 't_l1_q5', courseId: 'ta_teach_101', question: 'Why is it important to "Analyze" first?', options: ['To understand the learners\' needs', 'To skip the design phase', 'To save money', 'It is not important'], correctIndex: 0),
      ],
    ),
    Lesson(
      id: 't_l2',
      courseId: 'ta_teach_101',
      title: 'Engaging Students Virtually',
      durationMinutes: 30,
      orderIndex: 1,
      content: 'Online learning can be isolating. Keeping students engaged requires active effort.\n\nStrategies:\n• Use interactive polls and quizzes.\n• Encourage discussion in chat or forums.\n• Keep video lectures short (microlearning).\n• Provide timely and constructive feedback.',
      quizzes: [
        Quiz(id: 't_l2_q1', courseId: 'ta_teach_101', question: 'Why can online learning be challenging for students?', options: ['It is too easy', 'It can feel isolating', 'There are no exams', 'It is too fast'], correctIndex: 1),
        Quiz(id: 't_l2_q2', courseId: 'ta_teach_101', question: 'Which is a good strategy to keep students engaged?', options: ['2-hour long lectures', 'Ignoring questions', 'Interactive polls and quizzes', 'Reading from a slide'], correctIndex: 2),
        Quiz(id: 't_l2_q3', courseId: 'ta_teach_101', question: 'What is microlearning?', options: ['Learning with microscopes', 'Keeping learning modules short and focused', 'Learning slowly', 'Learning for babies'], correctIndex: 1),
        Quiz(id: 't_l2_q4', courseId: 'ta_teach_101', question: 'How should feedback be delivered online?', options: ['Never', 'Timely and constructively', 'Only at the end of the year', 'Harshly'], correctIndex: 1),
        Quiz(id: 't_l2_q5', courseId: 'ta_teach_101', question: 'What tool can foster community in an online course?', options: ['A calculator', 'Discussion forums', 'A textbook', 'A timer'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 't_l3',
      courseId: 'ta_teach_101',
      title: 'Tools for E-Learning',
      durationMinutes: 20,
      orderIndex: 2,
      content: 'A modern online teacher uses various tools to facilitate learning.\n\n• LMS (Learning Management System): Platforms like Canvas, Moodle, or Blackboard to host the course.\n• Video Conferencing: Zoom, Google Meet for live sessions.\n• Content Creation: Canva for graphics, Camtasia for video editing.\n• Assessment: Google Forms, Kahoot for quizzes.',
      quizzes: [
        Quiz(id: 't_l3_q1', courseId: 'ta_teach_101', question: 'What does LMS stand for?', options: ['Learning Management System', 'Local Math System', 'Live Meeting Software', 'Large Media Server'], correctIndex: 0),
        Quiz(id: 't_l3_q2', courseId: 'ta_teach_101', question: 'Which of the following is an LMS?', options: ['Zoom', 'Canvas', 'Canva', 'Photoshop'], correctIndex: 1),
        Quiz(id: 't_l3_q3', courseId: 'ta_teach_101', question: 'What tool is best for live virtual classes?', options: ['Moodle', 'Microsoft Word', 'Zoom', 'Kahoot'], correctIndex: 2),
        Quiz(id: 't_l3_q4', courseId: 'ta_teach_101', question: 'What is Kahoot commonly used for?', options: ['Video editing', 'Interactive quizzes/assessments', 'Writing essays', 'Hosting websites'], correctIndex: 1),
        Quiz(id: 't_l3_q5', courseId: 'ta_teach_101', question: 'Which tool is great for creating graphics and presentations easily?', options: ['Excel', 'Canva', 'Notepad', 'Calculator'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 't_l4',
      courseId: 'ta_teach_101',
      title: 'Creating Effective Assessments',
      durationMinutes: 30,
      orderIndex: 3,
      content: 'Assessments evaluate student understanding.\n\nFormative Assessments: Low-stakes evaluations during learning (e.g., polls, short quizzes) to identify gaps.\nSummative Assessments: High-stakes evaluations at the end (e.g., final exams, major projects).\n\nGood questions should align with the learning objectives and avoid trick wording.',
      quizzes: [
        Quiz(id: 't_l4_q1', courseId: 'ta_teach_101', question: 'What is a formative assessment?', options: ['A final exam', 'A low-stakes evaluation during learning', 'A grading curve', 'A textbook'], correctIndex: 1),
        Quiz(id: 't_l4_q2', courseId: 'ta_teach_101', question: 'What is a summative assessment?', options: ['A quick poll', 'A high-stakes evaluation at the end', 'An icebreaker', 'A syllabus'], correctIndex: 1),
        Quiz(id: 't_l4_q3', courseId: 'ta_teach_101', question: 'Questions should ideally align with...', options: ['The teacher\'s hobbies', 'The learning objectives', 'Random topics', 'Nothing'], correctIndex: 1),
        Quiz(id: 't_l4_q4', courseId: 'ta_teach_101', question: 'Which is an example of a formative assessment?', options: ['Final Exam', 'Term Paper', 'A quick mid-lecture Kahoot quiz', 'Graduation'], correctIndex: 2),
        Quiz(id: 't_l4_q5', courseId: 'ta_teach_101', question: 'Should assessment questions contain trick wording?', options: ['Yes', 'No, they should be clear', 'Only for smart students', 'Always'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 't_l5',
      courseId: 'ta_teach_101',
      title: 'Accessibility in E-Learning',
      durationMinutes: 25,
      orderIndex: 4,
      content: 'Courses must be accessible to all students, including those with disabilities.\n\nBest Practices:\n• Add closed captions to videos for the hearing impaired.\n• Use alt-text for images so screen readers can describe them.\n• Ensure high color contrast between text and background.\n• Use clear, readable fonts.',
      quizzes: [
        Quiz(id: 't_l5_q1', courseId: 'ta_teach_101', question: 'What does accessibility mean in e-learning?', options: ['The course is cheap', 'The course is usable by all students, including those with disabilities', 'The course is short', 'The course is on a mobile app'], correctIndex: 1),
        Quiz(id: 't_l5_q2', courseId: 'ta_teach_101', question: 'Why should videos have closed captions?', options: ['For SEO', 'For students who are hearing impaired', 'To make the video longer', 'Because it looks professional'], correctIndex: 1),
        Quiz(id: 't_l5_q3', courseId: 'ta_teach_101', question: 'What is "alt-text" used for?', options: ['Describing images for screen readers', 'Translating text', 'Changing fonts', 'Making text bold'], correctIndex: 0),
        Quiz(id: 't_l5_q4', courseId: 'ta_teach_101', question: 'Which color combination is bad for accessibility?', options: ['Black text on white', 'White text on black', 'Yellow text on white', 'Dark blue on light gray'], correctIndex: 2),
        Quiz(id: 't_l5_q5', courseId: 'ta_teach_101', question: 'Fonts in e-learning should be...', options: ['Tiny', 'Cursive', 'Clear and readable', 'Bright red'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 't_l6',
      courseId: 'ta_teach_101',
      title: 'Managing Virtual Classrooms',
      durationMinutes: 35,
      orderIndex: 5,
      content: 'Managing a live virtual class requires structure.\n\nTips:\n• Establish ground rules early (e.g., "Mute microphones when not speaking").\n• Have a backup plan if technology fails.\n• Use breakout rooms for small group work.\n• Start and end on time to respect students\' schedules.',
      quizzes: [
        Quiz(id: 't_l6_q1', courseId: 'ta_teach_101', question: 'What is a good ground rule for virtual classes?', options: ['Everyone talks at once', 'Mute microphones when not speaking', 'Keep cameras off always', 'Arrive late'], correctIndex: 1),
        Quiz(id: 't_l6_q2', courseId: 'ta_teach_101', question: 'What should you do if your internet drops during a live class?', options: ['Panic', 'Have a backup plan (like a mobile hotspot or recorded video)', 'Cancel the course', 'Blame the students'], correctIndex: 1),
        Quiz(id: 't_l6_q3', courseId: 'ta_teach_101', question: 'What feature allows for small group work in Zoom?', options: ['Chat', 'Screen Share', 'Breakout Rooms', 'Reactions'], correctIndex: 2),
        Quiz(id: 't_l6_q4', courseId: 'ta_teach_101', question: 'Why should you start and end on time?', options: ['To respect students\' schedules', 'Because the software will crash', 'To get paid more', 'It does not matter'], correctIndex: 0),
        Quiz(id: 't_l6_q5', courseId: 'ta_teach_101', question: 'Who is responsible for managing the virtual classroom?', options: ['The students', 'The software developer', 'The teacher/instructor', 'The principal'], correctIndex: 2),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 't_final_q1', courseId: 'ta_teach_101', question: 'What is the ADDIE model used for?', options: ['Math formulas', 'Instructional design', 'Cooking', 'Programming'], correctIndex: 1),
    Quiz(id: 't_final_q2', courseId: 'ta_teach_101', question: 'What is a key benefit of microlearning?', options: ['Takes 5 years', 'Keeps learners engaged with short content', 'Is very expensive', 'Requires VR headsets'], correctIndex: 1),
    Quiz(id: 't_final_q3', courseId: 'ta_teach_101', question: 'What is a formative assessment?', options: ['A final exam', 'A low-stakes check-in', 'A grade', 'A syllabus'], correctIndex: 1),
    Quiz(id: 't_final_q4', courseId: 'ta_teach_101', question: 'Why use alt-text?', options: ['For screen readers', 'For color', 'For video', 'For fun'], correctIndex: 0),
    Quiz(id: 't_final_q5', courseId: 'ta_teach_101', question: 'What phase of ADDIE involves creating the course materials?', options: ['Analyze', 'Evaluate', 'Develop', 'Implement'], correctIndex: 2),
  ],
);
