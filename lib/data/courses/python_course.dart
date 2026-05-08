import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course pythonCourse = Course(
  id: 'dev_python_101',
  title: 'Python for Beginners',
  description: 'Master Python programming basics. Learn about data structures, loops, functions, and file handling.',
  category: 'Development',
  icon: Icons.code_rounded,
  color: const Color(0xFF3776AB), // Python blue
  gradientEnd: const Color(0xFFFFD43B), // Python yellow
  lessons: const [
    Lesson(
      id: 'p_l1',
      courseId: 'dev_python_101',
      title: 'Python Basics & Variables',
      durationMinutes: 20,
      orderIndex: 0,
      youtubeVideoId: 'kqtD5dpn9C8', // Python for Beginners
      content: 'Python is a high-level, interpreted programming language known for its readability.\n\nVariables are created the moment you first assign a value to them. Python has no command for declaring a variable.\nExample:\nx = 5\ny = "Hello, World!"\n\nData Types include: int, float, str, bool, list, tuple, dict.',
      quizzes: [
        Quiz(id: 'p_l1_q1', courseId: 'dev_python_101', question: 'What kind of language is Python?', options: ['Compiled', 'Interpreted', 'Assembly', 'Machine'], correctIndex: 1),
        Quiz(id: 'p_l1_q2', courseId: 'dev_python_101', question: 'How do you create a variable with the numeric value 5?', options: ['int x = 5;', 'x = 5', 'let x = 5', 'var x = 5;'], correctIndex: 1),
        Quiz(id: 'p_l1_q3', courseId: 'dev_python_101', question: 'Which is a correct string in Python?', options: ['"Hello"', "'Hello'", 'Both A and B', 'None'], correctIndex: 2),
        Quiz(id: 'p_l1_q4', courseId: 'dev_python_101', question: 'What is the output of print(type(5))?', options: ['<class \'int\'>', '<class \'str\'>', '<class \'float\'>', '<class \'number\'>'], correctIndex: 0),
        Quiz(id: 'p_l1_q5', courseId: 'dev_python_101', question: 'Python is known for its...', options: ['Complex syntax', 'Speed', 'Readability', 'Memory management'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'p_l2',
      courseId: 'dev_python_101',
      title: 'Control Flow (If/Else & Loops)',
      durationMinutes: 30,
      orderIndex: 1,
      content: 'Control flow allows you to dictate the order in which code executes.\n\nIf/Else:\nif a > b:\n  print("a is greater")\nelse:\n  print("b is greater")\n\nLoops:\n• for loop: Used for iterating over a sequence (list, tuple, dictionary, set, or string).\n• while loop: Executes a set of statements as long as a condition is true.',
      quizzes: [
        Quiz(id: 'p_l2_q1', courseId: 'dev_python_101', question: 'How do you write an "if" statement in Python?', options: ['if x > y then:', 'if (x > y)', 'if x > y:', 'if x > y'], correctIndex: 2),
        Quiz(id: 'p_l2_q2', courseId: 'dev_python_101', question: 'Which loop is used to iterate over a sequence?', options: ['for', 'while', 'do-while', 'foreach'], correctIndex: 0),
        Quiz(id: 'p_l2_q3', courseId: 'dev_python_101', question: 'What is the keyword for "else if" in Python?', options: ['elseif', 'else if', 'elif', 'elsif'], correctIndex: 2),
        Quiz(id: 'p_l2_q4', courseId: 'dev_python_101', question: 'How do you stop a loop prematurely?', options: ['stop', 'break', 'exit', 'return'], correctIndex: 1),
        Quiz(id: 'p_l2_q5', courseId: 'dev_python_101', question: 'Which indentation does Python use to define scope?', options: ['Braces {}', 'Brackets []', 'Whitespace (spaces/tabs)', 'Parentheses ()'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'p_l3',
      courseId: 'dev_python_101',
      title: 'Functions',
      durationMinutes: 25,
      orderIndex: 2,
      content: 'A function is a block of code which only runs when it is called. You can pass data, known as parameters, into a function.\n\nIn Python, a function is defined using the def keyword.\n\nExample:\ndef my_function(name):\n  print("Hello " + name)\n\nmy_function("Alice")',
      quizzes: [
        Quiz(id: 'p_l3_q1', courseId: 'dev_python_101', question: 'Which keyword is used to create a function in Python?', options: ['function', 'def', 'create', 'fun'], correctIndex: 1),
        Quiz(id: 'p_l3_q2', courseId: 'dev_python_101', question: 'How do you call a function named "my_function"?', options: ['call my_function()', 'my_function()', 'my_function', 'execute my_function()'], correctIndex: 1),
        Quiz(id: 'p_l3_q3', courseId: 'dev_python_101', question: 'Information passed into a function is called?', options: ['Variables', 'Data', 'Arguments/Parameters', 'Returns'], correctIndex: 2),
        Quiz(id: 'p_l3_q4', courseId: 'dev_python_101', question: 'What keyword is used to send back a value from a function?', options: ['send', 'output', 'print', 'return'], correctIndex: 3),
        Quiz(id: 'p_l3_q5', courseId: 'dev_python_101', question: 'Can a Python function return multiple values?', options: ['Yes, as a tuple', 'No', 'Only as a list', 'Only as a string'], correctIndex: 0),
      ],
    ),
    Lesson(
      id: 'p_l4',
      courseId: 'dev_python_101',
      title: 'Data Structures',
      durationMinutes: 35,
      orderIndex: 3,
      content: 'Python has 4 built-in data structures used to store collections of data:\n\n1. List: Ordered and changeable. Allows duplicate members. Ex: `[1, 2, 3]`\n2. Tuple: Ordered and unchangeable. Allows duplicate members. Ex: `(1, 2, 3)`\n3. Set: Unordered, unchangeable, and unindexed. No duplicate members. Ex: `{1, 2, 3}`\n4. Dictionary: Ordered and changeable. No duplicate keys. Ex: `{"name": "John"}`',
      quizzes: [
        Quiz(id: 'p_l4_q1', courseId: 'dev_python_101', question: 'Which collection is ordered, changeable, and allows duplicates?', options: ['List', 'Tuple', 'Set', 'Dictionary'], correctIndex: 0),
        Quiz(id: 'p_l4_q2', courseId: 'dev_python_101', question: 'Which collection does NOT allow duplicate members?', options: ['List', 'Tuple', 'Set', 'Array'], correctIndex: 2),
        Quiz(id: 'p_l4_q3', courseId: 'dev_python_101', question: 'How do you define a dictionary?', options: ['[1, 2, 3]', '(1, 2, 3)', '{"key": "value"}', '1, 2, 3'], correctIndex: 2),
        Quiz(id: 'p_l4_q4', courseId: 'dev_python_101', question: 'What is true about Tuples?', options: ['They are changeable', 'They use square brackets', 'They are unchangeable', 'They cannot hold strings'], correctIndex: 2),
        Quiz(id: 'p_l4_q5', courseId: 'dev_python_101', question: 'Which data structure uses Key-Value pairs?', options: ['Set', 'List', 'Tuple', 'Dictionary'], correctIndex: 3),
      ],
    ),
    Lesson(
      id: 'p_l5',
      courseId: 'dev_python_101',
      title: 'Error Handling (Try/Except)',
      durationMinutes: 20,
      orderIndex: 4,
      content: 'When an error occurs, Python stops and generates an error message.\nWe can handle these using Try/Except blocks:\n\ntry:\n  # Code that might cause an error\n  print(x)\nexcept NameError:\n  # Code to run if NameError occurs\n  print("Variable x is not defined")\nexcept:\n  # Catch all other errors\n  print("Something else went wrong")\n\nThe `finally` block executes regardless of whether an error occurred.',
      quizzes: [
        Quiz(id: 'p_l5_q1', courseId: 'dev_python_101', question: 'Which keyword lets you test a block of code for errors?', options: ['try', 'except', 'finally', 'catch'], correctIndex: 0),
        Quiz(id: 'p_l5_q2', courseId: 'dev_python_101', question: 'Which keyword lets you handle the error?', options: ['try', 'catch', 'except', 'handle'], correctIndex: 2),
        Quiz(id: 'p_l5_q3', courseId: 'dev_python_101', question: 'What does the `finally` block do?', options: ['Executes only if there is an error', 'Executes regardless of an error', 'Stops the program', 'Skips the try block'], correctIndex: 1),
        Quiz(id: 'p_l5_q4', courseId: 'dev_python_101', question: 'Can you have multiple except blocks?', options: ['Yes', 'No', 'Only two', 'Only for syntax errors'], correctIndex: 0),
        Quiz(id: 'p_l5_q5', courseId: 'dev_python_101', question: 'What is the standard error type for an undefined variable?', options: ['TypeError', 'SyntaxError', 'ValueError', 'NameError'], correctIndex: 3),
      ],
    ),
    Lesson(
      id: 'p_l6',
      courseId: 'dev_python_101',
      title: 'File Handling',
      durationMinutes: 30,
      orderIndex: 5,
      content: 'Python has several functions for creating, reading, updating, and deleting files.\n\nThe key function for working with files in Python is the `open()` function.\nIt takes two parameters; filename, and mode.\n\nModes:\n"r" - Read - Default value. Opens a file for reading.\n"a" - Append - Opens a file for appending.\n"w" - Write - Opens a file for writing.\n"x" - Create - Creates the specified file.',
      quizzes: [
        Quiz(id: 'p_l6_q1', courseId: 'dev_python_101', question: 'Which function opens a file in Python?', options: ['read()', 'file()', 'open()', 'start()'], correctIndex: 2),
        Quiz(id: 'p_l6_q2', courseId: 'dev_python_101', question: 'What does the mode "r" stand for?', options: ['Read', 'Run', 'Remove', 'Replace'], correctIndex: 0),
        Quiz(id: 'p_l6_q3', courseId: 'dev_python_101', question: 'Which mode will overwrite any existing content in a file?', options: ['"a"', '"r"', '"w"', '"x"'], correctIndex: 2),
        Quiz(id: 'p_l6_q4', courseId: 'dev_python_101', question: 'Which mode is used to add new data to the end of a file?', options: ['"w"', '"a"', '"r"', '"e"'], correctIndex: 1),
        Quiz(id: 'p_l6_q5', courseId: 'dev_python_101', question: 'What is good practice after you are done with a file?', options: ['Delete it', 'Save it twice', 'Close it using file.close()', 'Leave it open'], correctIndex: 2),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 'p_final_q1', courseId: 'dev_python_101', question: 'Which collection does not allow duplicates?', options: ['List', 'Tuple', 'Set', 'Array'], correctIndex: 2),
    Quiz(id: 'p_final_q2', courseId: 'dev_python_101', question: 'Which keyword creates a function?', options: ['function', 'def', 'fun', 'define'], correctIndex: 1),
    Quiz(id: 'p_final_q3', courseId: 'dev_python_101', question: 'Which mode appends data to a file?', options: ['"w"', '"r"', '"a"', '"x"'], correctIndex: 2),
    Quiz(id: 'p_final_q4', courseId: 'dev_python_101', question: 'What handles errors in Python?', options: ['try/catch', 'try/except', 'do/while', 'if/else'], correctIndex: 1),
    Quiz(id: 'p_final_q5', courseId: 'dev_python_101', question: 'What does print(type(5.5)) output?', options: ['<class \'int\'>', '<class \'float\'>', '<class \'double\'>', '<class \'str\'>'], correctIndex: 1),
  ],
);
