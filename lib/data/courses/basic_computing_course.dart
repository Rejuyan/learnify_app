import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course basicComputingCourse = Course(
  id: 'bl_comp_101',
  title: 'Digital Literacy & Computing',
  description: 'A beginner-friendly introduction to using computers, surfing the web safely, and basic office software.',
  category: 'Basic Learning',
  icon: Icons.mouse_rounded,
  color: const Color(0xFF00BCD4), // Cyan
  gradientEnd: const Color(0xFF0097A7),
  lessons: const [
    Lesson(
      id: 'bc_l1',
      courseId: 'bl_comp_101',
      title: 'Understanding the Computer',
      durationMinutes: 20,
      orderIndex: 0,
      content: 'A computer consists of Hardware (physical parts) and Software (programs).\n\nKey Hardware:\n• CPU (Central Processing Unit): The brain.\n• RAM (Random Access Memory): Short-term memory.\n• Hard Drive/SSD: Long-term storage.\n\nSoftware:\n• Operating System (Windows, macOS, Linux): Manages the hardware and allows you to run applications.',
      quizzes: [
        Quiz(id: 'bc_l1_q1', courseId: 'bl_comp_101', question: 'What is considered the "brain" of the computer?', options: ['RAM', 'Hard Drive', 'CPU', 'Monitor'], correctIndex: 2),
        Quiz(id: 'bc_l1_q2', courseId: 'bl_comp_101', question: 'What does RAM stand for?', options: ['Random Access Memory', 'Read Access Memory', 'Run All Machines', 'Real Active Memory'], correctIndex: 0),
        Quiz(id: 'bc_l1_q3', courseId: 'bl_comp_101', question: 'Which of the following is an Operating System?', options: ['Microsoft Word', 'Windows', 'Google Chrome', 'Keyboard'], correctIndex: 1),
        Quiz(id: 'bc_l1_q4', courseId: 'bl_comp_101', question: 'What type of memory is used for long-term storage?', options: ['RAM', 'Cache', 'Hard Drive / SSD', 'CPU Register'], correctIndex: 2),
        Quiz(id: 'bc_l1_q5', courseId: 'bl_comp_101', question: 'Physical parts of a computer are called...', options: ['Software', 'Malware', 'Hardware', 'Programs'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'bc_l2',
      courseId: 'bl_comp_101',
      title: 'Internet Safety Basics',
      durationMinutes: 25,
      orderIndex: 1,
      content: 'Staying safe online is crucial.\n\nBest Practices:\n• Use strong, unique passwords for different accounts.\n• Do not click on suspicious links in emails (Phishing).\n• Keep your operating system and antivirus software updated.\n• Be careful what personal information you share on social media.',
      quizzes: [
        Quiz(id: 'bc_l2_q1', courseId: 'bl_comp_101', question: 'What makes a strong password?', options: ['Your name', '123456', 'A mix of letters, numbers, and symbols', 'The word "password"'], correctIndex: 2),
        Quiz(id: 'bc_l2_q2', courseId: 'bl_comp_101', question: 'What is "Phishing"?', options: ['Catching fish', 'Fake emails designed to steal your info', 'A type of computer virus', 'A safe website'], correctIndex: 1),
        Quiz(id: 'bc_l2_q3', courseId: 'bl_comp_101', question: 'Why should you update your software?', options: ['To make the computer slower', 'To patch security vulnerabilities', 'To change the screen color', 'You shouldn\'t update it'], correctIndex: 1),
        Quiz(id: 'bc_l2_q4', courseId: 'bl_comp_101', question: 'Is it safe to use the same password everywhere?', options: ['Yes, it is easy to remember', 'No, if one site is hacked, all are at risk', 'Only on social media', 'Only for banks'], correctIndex: 1),
        Quiz(id: 'bc_l2_q5', courseId: 'bl_comp_101', question: 'Which is a safe practice on social media?', options: ['Sharing your home address', 'Accepting all friend requests', 'Keeping privacy settings strict', 'Posting your credit card'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'bc_l3',
      courseId: 'bl_comp_101',
      title: 'Introduction to Office Software',
      durationMinutes: 30,
      orderIndex: 2,
      content: 'Office software helps with productivity.\n\n• Word Processors (e.g., MS Word, Google Docs): Used for writing documents, letters, and reports.\n• Spreadsheets (e.g., MS Excel, Google Sheets): Used for data entry, calculations, and charting.\n• Presentation Software (e.g., MS PowerPoint, Google Slides): Used to create visual slideshows.',
      quizzes: [
        Quiz(id: 'bc_l3_q1', courseId: 'bl_comp_101', question: 'Which software is best for writing a formal letter?', options: ['MS Excel', 'MS Paint', 'MS Word', 'MS PowerPoint'], correctIndex: 2),
        Quiz(id: 'bc_l3_q2', courseId: 'bl_comp_101', question: 'What is a Spreadsheet primarily used for?', options: ['Editing videos', 'Writing books', 'Calculations and data entry', 'Browsing the web'], correctIndex: 2),
        Quiz(id: 'bc_l3_q3', courseId: 'bl_comp_101', question: 'Which program would you use to create a slideshow for a meeting?', options: ['Google Docs', 'MS PowerPoint', 'Notepad', 'Calculator'], correctIndex: 1),
        Quiz(id: 'bc_l3_q4', courseId: 'bl_comp_101', question: 'What is Google Docs?', options: ['An operating system', 'A cloud-based word processor', 'A game', 'A web browser'], correctIndex: 1),
        Quiz(id: 'bc_l3_q5', courseId: 'bl_comp_101', question: 'Which tool uses Rows and Columns (Cells)?', options: ['Word Processor', 'Presentation Software', 'Spreadsheet', 'Email Client'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'bc_l4',
      courseId: 'bl_comp_101',
      title: 'File Management',
      durationMinutes: 20,
      orderIndex: 3,
      content: 'Organizing your files makes them easier to find.\n\n• Folders/Directories: Used to group related files.\n• File Extensions: The suffix at the end of a filename (e.g., .txt, .jpg, .pdf) that tells the OS what kind of file it is.\n• Backups: Always keep copies of important files on an external drive or cloud storage (Google Drive, OneDrive).',
      quizzes: [
        Quiz(id: 'bc_l4_q1', courseId: 'bl_comp_101', question: 'What is used to group related files together?', options: ['A spreadsheet', 'A folder/directory', 'A monitor', 'A virus'], correctIndex: 1),
        Quiz(id: 'bc_l4_q2', courseId: 'bl_comp_101', question: 'What does a file extension (like .jpg or .pdf) do?', options: ['Makes the file bigger', 'Tells the computer what kind of file it is', 'Hides the file', 'Deletes the file'], correctIndex: 1),
        Quiz(id: 'bc_l4_q3', courseId: 'bl_comp_101', question: 'Which of the following is an image file extension?', options: ['.txt', '.exe', '.jpg', '.docx'], correctIndex: 2),
        Quiz(id: 'bc_l4_q4', courseId: 'bl_comp_101', question: 'Why is it important to backup files?', options: ['To waste space', 'In case the original files are lost or corrupted', 'To make the computer slower', 'It is not important'], correctIndex: 1),
        Quiz(id: 'bc_l4_q5', courseId: 'bl_comp_101', question: 'Which of the following is a cloud storage service?', options: ['Microsoft Word', 'Google Drive', 'Windows', 'Notepad'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'bc_l5',
      courseId: 'bl_comp_101',
      title: 'Email Etiquette',
      durationMinutes: 15,
      orderIndex: 4,
      content: 'Writing professional emails is a crucial digital skill.\n\n• Subject Line: Should be clear and concise.\n• Salutation: Use a professional greeting (Dear, Hello).\n• Body: Get to the point, use paragraphs.\n• Sign-off: End politely (Best regards, Sincerely) with your name.\n• Reply All: Only use this if everyone on the thread needs to see your response.',
      quizzes: [
        Quiz(id: 'bc_l5_q1', courseId: 'bl_comp_101', question: 'What should the subject line of an email be?', options: ['Left blank', 'A full paragraph', 'Clear and concise', 'A joke'], correctIndex: 2),
        Quiz(id: 'bc_l5_q2', courseId: 'bl_comp_101', question: 'Which is a professional email sign-off?', options: ['See ya', 'Best regards', 'Bye', 'Peace out'], correctIndex: 1),
        Quiz(id: 'bc_l5_q3', courseId: 'bl_comp_101', question: 'When should you use "Reply All"?', options: ['Always', 'Never', 'Only when everyone on the thread needs the info', 'When you want to annoy people'], correctIndex: 2),
        Quiz(id: 'bc_l5_q4', courseId: 'bl_comp_101', question: 'Is writing an email in ALL CAPS a good idea?', options: ['Yes, it shows importance', 'No, it looks like shouting', 'Only on Fridays', 'Yes, it is easier to read'], correctIndex: 1),
        Quiz(id: 'bc_l5_q5', courseId: 'bl_comp_101', question: 'What should you do before clicking send?', options: ['Close your eyes', 'Proofread for errors', 'Delete the message', 'Add 10 emojis'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'bc_l6',
      courseId: 'bl_comp_101',
      title: 'Troubleshooting Basics',
      durationMinutes: 20,
      orderIndex: 5,
      content: 'Sometimes computers don\'t work as expected. Basic troubleshooting can fix many issues.\n\n1. Restart the computer (fixes 80% of temporary glitches).\n2. Check physical connections (cables, power).\n3. Force quit frozen applications.\n4. Use a search engine to look up error codes.',
      quizzes: [
        Quiz(id: 'bc_l6_q1', courseId: 'bl_comp_101', question: 'What is often the first step in troubleshooting a glitchy computer?', options: ['Buy a new one', 'Restart it', 'Hit it', 'Delete everything'], correctIndex: 1),
        Quiz(id: 'bc_l6_q2', courseId: 'bl_comp_101', question: 'If your monitor is completely black, what should you check first?', options: ['The internet connection', 'Physical power and display cables', 'The antivirus', 'The keyboard'], correctIndex: 1),
        Quiz(id: 'bc_l6_q3', courseId: 'bl_comp_101', question: 'What should you do if an application freezes completely?', options: ['Wait forever', 'Force quit the application', 'Unplug the computer from the wall', 'Scream'], correctIndex: 1),
        Quiz(id: 'bc_l6_q4', courseId: 'bl_comp_101', question: 'If you get a specific error code, what is the best way to find a solution?', options: ['Guess what it means', 'Search the error code on Google', 'Call the police', 'Ignore it'], correctIndex: 1),
        Quiz(id: 'bc_l6_q5', courseId: 'bl_comp_101', question: 'True or False: Restarting the computer can fix temporary software issues.', options: ['True', 'False', 'Only on Mac', 'Only on Windows'], correctIndex: 0),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 'bc_final_q1', courseId: 'bl_comp_101', question: 'What is the CPU?', options: ['Storage', 'The brain of the computer', 'A typing device', 'A screen'], correctIndex: 1),
    Quiz(id: 'bc_final_q2', courseId: 'bl_comp_101', question: 'What does an Operating System do?', options: ['Cools the computer', 'Manages hardware and software', 'Types documents', 'Prints pictures'], correctIndex: 1),
    Quiz(id: 'bc_final_q3', courseId: 'bl_comp_101', question: 'What is a file extension?', options: ['A long wire', 'The suffix indicating file type (e.g. .jpg)', 'A virus', 'A large folder'], correctIndex: 1),
    Quiz(id: 'bc_final_q4', courseId: 'bl_comp_101', question: 'Which software is best for mathematical calculations?', options: ['MS Word', 'Google Slides', 'MS Excel', 'Photoshop'], correctIndex: 2),
    Quiz(id: 'bc_final_q5', courseId: 'bl_comp_101', question: 'What is the first step in troubleshooting?', options: ['Buy a new PC', 'Restart the computer', 'Delete Windows', 'Format the hard drive'], correctIndex: 1),
  ],
);
