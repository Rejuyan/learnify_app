import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course designCourse = Course(
  id: 'des_graphic_101',
  title: 'Graphic Design Basics',
  description: 'Master the fundamentals of color theory, typography, and composition to create stunning visuals.',
  category: 'Design',
  icon: Icons.brush_rounded,
  color: const Color(0xFFE91E63), // Pink
  gradientEnd: const Color(0xFFC2185B),
  lessons: const [
    Lesson(
      id: 'd_l1',
      courseId: 'des_graphic_101',
      title: 'Introduction to Graphic Design',
      durationMinutes: 20,
      orderIndex: 0,
      content: 'Graphic design is the art of communicating visually using typography, imagery, color, and form.\n\nIt is used in branding, marketing, web design, and UI/UX.\nGood design solves problems and communicates a clear message to the audience.',
      quizzes: [
        Quiz(id: 'd_l1_q1', courseId: 'des_graphic_101', question: 'What is the primary purpose of graphic design?', options: ['To make things look pretty', 'To communicate visually', 'To write code', 'To take photographs'], correctIndex: 1),
        Quiz(id: 'd_l1_q2', courseId: 'des_graphic_101', question: 'Which of these is NOT a core element of graphic design?', options: ['Typography', 'Color', 'Sound effects', 'Form/Shape'], correctIndex: 2),
        Quiz(id: 'd_l1_q3', courseId: 'des_graphic_101', question: 'Good design should primarily...', options: ['Solve problems and communicate a message', 'Confuse the viewer', 'Use every color possible', 'Be invisible'], correctIndex: 0),
        Quiz(id: 'd_l1_q4', courseId: 'des_graphic_101', question: 'Where is graphic design commonly used?', options: ['Branding and Marketing', 'Cooking', 'Accounting', 'Surgery'], correctIndex: 0),
        Quiz(id: 'd_l1_q5', courseId: 'des_graphic_101', question: 'True or False: Graphic design is only about drawing.', options: ['True', 'False', 'Only for logos', 'Only for web'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'd_l2',
      courseId: 'des_graphic_101',
      title: 'Color Theory',
      durationMinutes: 30,
      orderIndex: 1,
      content: 'Color theory helps designers choose color palettes that are harmonious and effective.\n\n• Primary Colors: Red, Blue, Yellow.\n• Secondary Colors: Green, Orange, Purple.\n• Complementary Colors: Colors opposite each other on the color wheel (e.g., Red & Green). They create high contrast.',
      quizzes: [
        Quiz(id: 'd_l2_q1', courseId: 'des_graphic_101', question: 'Which of the following is a Primary Color?', options: ['Green', 'Orange', 'Blue', 'Purple'], correctIndex: 2),
        Quiz(id: 'd_l2_q2', courseId: 'des_graphic_101', question: 'What are Secondary Colors made from?', options: ['Mixing black and white', 'Mixing two primary colors', 'Mixing water and paint', 'They cannot be mixed'], correctIndex: 1),
        Quiz(id: 'd_l2_q3', courseId: 'des_graphic_101', question: 'What are complementary colors?', options: ['Colors next to each other on the wheel', 'Colors opposite each other on the wheel', 'Colors that look bad together', 'Only black and white'], correctIndex: 1),
        Quiz(id: 'd_l2_q4', courseId: 'des_graphic_101', question: 'What effect do complementary colors have when placed together?', options: ['Low contrast', 'High contrast', 'Invisibility', 'Blurriness'], correctIndex: 1),
        Quiz(id: 'd_l2_q5', courseId: 'des_graphic_101', question: 'Which is a complementary color pair?', options: ['Red and Green', 'Blue and Yellow', 'Red and Orange', 'Blue and Green'], correctIndex: 0),
      ],
    ),
    Lesson(
      id: 'd_l3',
      courseId: 'des_graphic_101',
      title: 'Typography',
      durationMinutes: 25,
      orderIndex: 2,
      content: 'Typography is the art of arranging text.\n\n• Serif: Fonts with little feet or tails (e.g., Times New Roman). Great for printed body text.\n• Sans-Serif: Fonts without feet (e.g., Arial, Roboto). Great for digital screens.\n• Hierarchy: Using size and weight (boldness) to guide the reader\'s eye to the most important text first.',
      quizzes: [
        Quiz(id: 'd_l3_q1', courseId: 'des_graphic_101', question: 'What is typography?', options: ['The art of taking photos', 'The art of arranging text', 'The art of choosing colors', 'The art of drawing maps'], correctIndex: 1),
        Quiz(id: 'd_l3_q2', courseId: 'des_graphic_101', question: 'What characterizes a Serif font?', options: ['It has no lines', 'It has little feet or tails on the letters', 'It is always cursive', 'It is always bold'], correctIndex: 1),
        Quiz(id: 'd_l3_q3', courseId: 'des_graphic_101', question: 'Which type of font is generally considered best for reading on digital screens?', options: ['Serif', 'Sans-Serif', 'Script', 'Decorative'], correctIndex: 1),
        Quiz(id: 'd_l3_q4', courseId: 'des_graphic_101', question: 'What is typographical hierarchy?', options: ['Using alphabetical order', 'Using size and weight to guide the eye', 'Making all text the same size', 'Hiding text'], correctIndex: 1),
        Quiz(id: 'd_l3_q5', courseId: 'des_graphic_101', question: 'Which of the following is a Sans-Serif font?', options: ['Times New Roman', 'Garamond', 'Arial', 'Georgia'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'd_l4',
      courseId: 'des_graphic_101',
      title: 'Composition & Layout',
      durationMinutes: 30,
      orderIndex: 3,
      content: 'Composition is how elements are arranged on the canvas.\n\n• Rule of Thirds: Dividing the canvas into a 3x3 grid and placing the subject on the intersecting lines.\n• White Space (Negative Space): The empty space around elements. It prevents clutter and helps elements breathe.',
      quizzes: [
        Quiz(id: 'd_l4_q1', courseId: 'des_graphic_101', question: 'What does composition refer to in design?', options: ['The music playing in the background', 'How elements are arranged on the canvas', 'The colors used', 'The font size'], correctIndex: 1),
        Quiz(id: 'd_l4_q2', courseId: 'des_graphic_101', question: 'What is the Rule of Thirds?', options: ['Using only 3 colors', 'Dividing the canvas into a 3x3 grid', 'Writing 3 words', 'Having 3 images'], correctIndex: 1),
        Quiz(id: 'd_l4_q3', courseId: 'des_graphic_101', question: 'Where should the focal point be placed according to the Rule of Thirds?', options: ['Dead center', 'In the corners', 'On the intersecting lines of the grid', 'Outside the canvas'], correctIndex: 2),
        Quiz(id: 'd_l4_q4', courseId: 'des_graphic_101', question: 'What is White Space (Negative Space)?', options: ['Space that is painted white', 'The empty space around elements', 'Outer space', 'Mistakes in the design'], correctIndex: 1),
        Quiz(id: 'd_l4_q5', courseId: 'des_graphic_101', question: 'Why is white space important?', options: ['It saves ink', 'It prevents clutter and lets elements breathe', 'It makes the design look unfinished', 'It is a requirement of the software'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'd_l5',
      courseId: 'des_graphic_101',
      title: 'Vector vs Raster',
      durationMinutes: 25,
      orderIndex: 4,
      content: 'Images fall into two main categories:\n\n• Raster (Bitmap): Made of pixels. If you zoom in, they get blurry/pixelated. Best for photographs. (e.g., .jpg, .png).\n• Vector: Made of mathematical paths. They can be scaled infinitely without losing quality. Best for logos and icons. (e.g., .svg, .eps).',
      quizzes: [
        Quiz(id: 'd_l5_q1', courseId: 'des_graphic_101', question: 'What are raster images made of?', options: ['Math equations', 'Pixels', 'Lines', 'Vectors'], correctIndex: 1),
        Quiz(id: 'd_l5_q2', courseId: 'des_graphic_101', question: 'What happens when you zoom in on a raster image?', options: ['It gets sharper', 'It stays the same', 'It gets pixelated/blurry', 'It changes color'], correctIndex: 2),
        Quiz(id: 'd_l5_q3', courseId: 'des_graphic_101', question: 'What are vector images made of?', options: ['Pixels', 'Mathematical paths', 'Photographs', 'Tiny dots'], correctIndex: 1),
        Quiz(id: 'd_l5_q4', courseId: 'des_graphic_101', question: 'Which image type can be scaled infinitely without losing quality?', options: ['Raster', 'Vector', 'Bitmap', 'JPEG'], correctIndex: 1),
        Quiz(id: 'd_l5_q5', courseId: 'des_graphic_101', question: 'Which format is best for a company logo that will be printed on both business cards and giant billboards?', options: ['Raster (.jpg)', 'Vector (.svg or .eps)', 'Raster (.png)', 'GIF'], correctIndex: 1),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 'd_final_q1', courseId: 'des_graphic_101', question: 'What is the primary goal of graphic design?', options: ['Visual communication', 'Painting', 'Coding', 'Writing'], correctIndex: 0),
    Quiz(id: 'd_final_q2', courseId: 'des_graphic_101', question: 'Which colors provide the highest contrast?', options: ['Analogous colors', 'Complementary colors', 'Primary colors', 'Pastel colors'], correctIndex: 1),
    Quiz(id: 'd_final_q3', courseId: 'des_graphic_101', question: 'Which font type is best for digital screens?', options: ['Serif', 'Sans-Serif', 'Script', 'Monospace'], correctIndex: 1),
    Quiz(id: 'd_final_q4', courseId: 'des_graphic_101', question: 'What prevents a design from looking cluttered?', options: ['Lots of text', 'White space / Negative space', 'Bright colors', 'Many images'], correctIndex: 1),
    Quiz(id: 'd_final_q5', courseId: 'des_graphic_101', question: 'Which image format can scale infinitely?', options: ['Vector', 'Raster', 'Bitmap', 'JPEG'], correctIndex: 0),
  ],
);
