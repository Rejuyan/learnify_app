import { initializeApp } from 'firebase/app';
import { getFirestore, doc, setDoc } from 'firebase/firestore';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import readline from 'readline';

const firebaseConfig = {
  apiKey: 'AIzaSyAzwpo8Q_eVQkXfwNMc5BJstz-QYSNoGc4',
  authDomain: 'learnify-2a174.firebaseapp.com',
  projectId: 'learnify-2a174',
  storageBucket: 'learnify-2a174.firebasestorage.app',
  messagingSenderId: '553001438440',
  appId: '1:553001438440:web:3dc029955bf8e34272cd5d',
  measurementId: 'G-RNYPNTC09J',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

const coursesToSeed = [
  {
    id: "flutter_dev",
    title: "Flutter App Development",
    description: "Master cross-platform mobile development using Flutter and Dart from scratch.",
    category: "Technology",
    color: 0xFF02569B,
    gradientEnd: 0xFF0175C2,
    icon: {
      codePoint: 0xe18c, // code
      fontFamily: "MaterialIcons"
    },
    lessons: [
      {
        id: "flutter_dev_l1",
        courseId: "flutter_dev",
        title: "1. Introduction to Flutter & Dart",
        content: "Welcome to Flutter App Development! Flutter is Google's open-source UI SDK used to build premium native applications for mobile, web, and desktop from a single codebase.\n\nIn this lesson, you will learn the foundational concepts of the Dart programming language, including variables, functions, and key object-oriented programming concepts that drive Flutter UI layouts.",
        durationMinutes: 15,
        orderIndex: 0,
        youtubeVideoId: "1ukSR1GRtMU",
        quizzes: [
          {
            id: "flutter_dev_l1_q1",
            courseId: "flutter_dev",
            question: "What programming language is used to write Flutter applications?",
            options: ["Java", "Swift", "Dart", "JavaScript"],
            correctIndex: 2
          }
        ]
      },
      {
        id: "flutter_dev_l2",
        courseId: "flutter_dev",
        title: "2. Understanding Widgets: Stateless vs Stateful",
        content: "In Flutter, 'everything is a widget'. A widget represents an immutable description of part of a user interface.\n\nThere are two main types of widgets:\n* **StatelessWidget:** A widget that does not require mutable state. It is drawn once and never changes in response to user actions or events.\n* **StatefulWidget:** A widget that has mutable state. It can rebuild itself dynamically when state updates occur (e.g., when a user taps a button or types into a text field).",
        durationMinutes: 20,
        orderIndex: 1,
        youtubeVideoId: "wE7khGHHyDy",
        quizzes: [
          {
            id: "flutter_dev_l2_q1",
            courseId: "flutter_dev",
            question: "Which widget should you use if the UI needs to update dynamically based on user interaction?",
            options: ["StatelessWidget", "StatefulWidget", "InheritedWidget", "ConstWidget"],
            correctIndex: 1
          }
        ]
      }
    ],
    quizzes: [
      {
        id: "flutter_dev_q1",
        courseId: "flutter_dev",
        question: "What is the main benefit of using Flutter?",
        options: [
          "Single codebase for multiple platforms",
          "It only supports Android",
          "It compiles to interpreted JS only",
          "It does not require any programming"
        ],
        correctIndex: 0
      }
    ]
  },
  {
    id: "python_prog",
    title: "Python Programming Essentials",
    description: "Learn the fundamentals of Python, the most popular language for Data Science, Scripting, and AI.",
    category: "Technology",
    color: 0xFFFFB74D,
    gradientEnd: 0xFFFF9800,
    icon: {
      codePoint: 0xe1b1, // computer
      fontFamily: "MaterialIcons"
    },
    lessons: [
      {
        id: "python_prog_l1",
        courseId: "python_prog",
        title: "1. Getting Started & Syntax",
        content: "Welcome to Python! Python is a high-level, interpreted, general-purpose programming language known for its extreme readability and clean syntax.\n\nIn this lesson, you will master the basics of variables, mathematical operations, and printing output. Python is whitespace-sensitive, meaning indentation is strictly used to define code blocks instead of curly braces.",
        durationMinutes: 12,
        orderIndex: 0,
        youtubeVideoId: "rfscVS0vtbw",
        quizzes: [
          {
            id: "python_prog_l1_q1",
            courseId: "python_prog",
            question: "What does Python use to define code blocks instead of curly braces?",
            options: ["Semicolons", "Parentheses", "Indentation (Whitespace)", "Square brackets"],
            correctIndex: 2
          }
        ]
      },
      {
        id: "python_prog_l2",
        courseId: "python_prog",
        title: "2. Control Flow: If statements & Loops",
        content: "Control flow allows your programs to make decisions and execute actions repeatedly.\n\nIn Python, you can make decisions using `if`, `elif`, and `else` statements. You can repeat tasks using `for` loops (to iterate over a sequence) and `while` loops (to repeat as long as a condition is true).",
        durationMinutes: 18,
        orderIndex: 1,
        youtubeVideoId: "8nd-MJu-v44",
        quizzes: [
          {
            id: "python_prog_l2_q1",
            courseId: "python_prog",
            question: "Which loop is best suited to iterate over a list or sequence in Python?",
            options: ["while loop", "for loop", "do-while loop", "infinite loop"],
            correctIndex: 1
          }
        ]
      }
    ],
    quizzes: [
      {
        id: "python_prog_q1",
        courseId: "python_prog",
        question: "Which of the following is a valid Python data structure?",
        options: ["List", "Tuple", "Dictionary", "All of the above"],
        correctIndex: 3
      }
    ]
  },
  {
    id: "uiux_design",
    title: "UX/UI Design Principles",
    description: "Create stunning, modern, and user-centric interfaces using industry best practices.",
    category: "Design",
    color: 0xFFF06292,
    gradientEnd: 0xFFE91E63,
    icon: {
      codePoint: 0xe115, // brush
      fontFamily: "MaterialIcons"
    },
    lessons: [
      {
        id: "uiux_design_l1",
        courseId: "uiux_design",
        title: "1. The Design Thinking Process",
        content: "UX/UI design centers completely around the user. The Design Thinking process consists of five essential phases:\n\n1. **Empathize:** Research and understand your users' needs.\n2. **Define:** State your users' needs and problems clearly.\n3. **Ideate:** Brainstorm and challenge assumptions to create ideas.\n4. **Prototype:** Build interactive representations of your solutions.\n5. **Test:** Validate your prototypes with actual target users.",
        durationMinutes: 15,
        orderIndex: 0,
        youtubeVideoId: "a757U1566t8",
        quizzes: [
          {
            id: "uiux_design_l1_q1",
            courseId: "uiux_design",
            question: "What is the first step of the Design Thinking Process?",
            options: ["Ideate", "Prototype", "Define", "Empathize"],
            correctIndex: 3
          }
        ]
      }
    ],
    quizzes: [
      {
        id: "uiux_design_q1",
        courseId: "uiux_design",
        question: "What does 'UI' stand for in product design?",
        options: [
          "User Integration",
          "User Interface",
          "Universal Input",
          "Unique Identity"
        ],
        correctIndex: 1
      }
    ]
  }
];

function askPassword() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  return new Promise((resolve) => {
    rl.question('Enter password for admin@learnify.com: ', (answer) => {
      rl.close();
      resolve(answer);
    });
  });
}

async function seedFirestore() {
  const adminEmail = 'admin@learnify.com';
  console.log("Learnify Firestore Seeding Tool");
  const password = await askPassword();

  if (!password) {
    console.error("Password cannot be empty.");
    process.exit(1);
  }

  console.log(`Authenticating as ${adminEmail}...`);
  try {
    await signInWithEmailAndPassword(auth, adminEmail, password);
    console.log("Authentication successful! Seeding Firestore databases...");
  } catch (authError) {
    console.error("Authentication failed: ", authError.message || authError);
    process.exit(1);
  }

  try {
    for (const course of coursesToSeed) {
      console.log(`Uploading: ${course.title} (${course.id})`);
      await setDoc(doc(db, 'courses', course.id), course);
    }
    console.log("Firestore seeding completed successfully! All courses are online.");
    process.exit(0);
  } catch (error) {
    console.error("Firestore seeding failed with error: ", error);
    process.exit(1);
  }
}

seedFirestore();
