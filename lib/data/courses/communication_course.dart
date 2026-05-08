import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../models/quiz.dart';

final Course communicationCourse = Course(
  id: 'pd_comm_101',
  title: 'Mastering Communication Skills',
  description: 'Improve your public speaking, active listening, and business writing to accelerate your career.',
  category: 'Personal Development',
  icon: Icons.record_voice_over_rounded,
  color: const Color(0xFFF06292), // Pinkish
  gradientEnd: const Color(0xFFE91E63),
  lessons: const [
    Lesson(
      id: 'c_l1',
      courseId: 'pd_comm_101',
      title: 'The Art of Active Listening',
      durationMinutes: 20,
      orderIndex: 0,
      content: 'Communication is not just about speaking; it\'s equally about listening. Active listening involves fully concentrating, understanding, responding, and remembering what is being said.\n\nTechniques:\n• Maintain eye contact.\n• Don\'t interrupt.\n• Show that you are listening (nodding, saying "uh-huh").\n• Provide feedback by summarizing what they said.',
      quizzes: [
        Quiz(id: 'c_l1_q1', courseId: 'pd_comm_101', question: 'What is the most important part of communication often overlooked?', options: ['Talking loudly', 'Active listening', 'Using big words', 'Writing'], correctIndex: 1),
        Quiz(id: 'c_l1_q2', courseId: 'pd_comm_101', question: 'Which is a sign of active listening?', options: ['Looking at your phone', 'Interrupting the speaker', 'Maintaining eye contact', 'Thinking about your reply'], correctIndex: 2),
        Quiz(id: 'c_l1_q3', courseId: 'pd_comm_101', question: 'Why should you summarize what the speaker said?', options: ['To prove them wrong', 'To show you understand and provide feedback', 'To waste time', 'To make them repeat it'], correctIndex: 1),
        Quiz(id: 'c_l1_q4', courseId: 'pd_comm_101', question: 'What should you do when someone else is speaking?', options: ['Interrupt with your opinion', 'Plan what to say next', 'Give them your full concentration', 'Look away'], correctIndex: 2),
        Quiz(id: 'c_l1_q5', courseId: 'pd_comm_101', question: 'Active listening helps to build...', options: ['Arguments', 'Trust and rapport', 'Confusion', 'Boredom'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'c_l2',
      courseId: 'pd_comm_101',
      title: 'Public Speaking Fundamentals',
      durationMinutes: 30,
      orderIndex: 1,
      content: 'Public speaking is the process of communicating information to an audience. It is usually done before a large audience, like in school, the workplace, and even in our personal lives.\n\nTips for success:\n• Know your audience.\n• Outline your speech.\n• Practice, practice, practice.\n• Manage your body language (stand straight, use hand gestures naturally).',
      quizzes: [
        Quiz(id: 'c_l2_q1', courseId: 'pd_comm_101', question: 'What is the first rule of preparing a speech?', options: ['Know your audience', 'Write a joke', 'Memorize it word for word', 'Speak very fast'], correctIndex: 0),
        Quiz(id: 'c_l2_q2', courseId: 'pd_comm_101', question: 'Why is an outline important for a speech?', options: ['It makes it longer', 'It organizes your thoughts', 'It confuses the audience', 'It is not important'], correctIndex: 1),
        Quiz(id: 'c_l2_q3', courseId: 'pd_comm_101', question: 'How can you overcome stage fright?', options: ['Avoid speaking', 'Practice extensively', 'Drink coffee', 'Read from a paper'], correctIndex: 1),
        Quiz(id: 'c_l2_q4', courseId: 'pd_comm_101', question: 'What role does body language play in public speaking?', options: ['None', 'It contradicts the message', 'It reinforces the message', 'It distracts the audience'], correctIndex: 2),
        Quiz(id: 'c_l2_q5', courseId: 'pd_comm_101', question: 'When speaking to an audience, you should...', options: ['Stare at the floor', 'Maintain eye contact', 'Look at the ceiling', 'Close your eyes'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'c_l3',
      courseId: 'pd_comm_101',
      title: 'Effective Business Writing',
      durationMinutes: 25,
      orderIndex: 2,
      content: 'Business writing must be clear, concise, and professional. Whether you are writing an email, a report, or a proposal, the goal is to communicate information efficiently.\n\nBest Practices:\n• Get to the point quickly.\n• Keep sentences and paragraphs short.\n• Use bullet points for readability.\n• Proofread before sending.',
      quizzes: [
        Quiz(id: 'c_l3_q1', courseId: 'pd_comm_101', question: 'What are the key traits of business writing?', options: ['Long and complex', 'Clear and concise', 'Poetic and emotional', 'Vague and mysterious'], correctIndex: 1),
        Quiz(id: 'c_l3_q2', courseId: 'pd_comm_101', question: 'Why use bullet points in an email?', options: ['To hide information', 'To improve readability', 'To make it look longer', 'To add color'], correctIndex: 1),
        Quiz(id: 'c_l3_q3', courseId: 'pd_comm_101', question: 'What should you do before sending a professional email?', options: ['Delete it', 'Proofread it', 'Add emojis', 'Make the font huge'], correctIndex: 1),
        Quiz(id: 'c_l3_q4', courseId: 'pd_comm_101', question: 'In business writing, paragraphs should generally be...', options: ['Very long', 'One word', 'Short and focused', 'Complicated'], correctIndex: 2),
        Quiz(id: 'c_l3_q5', courseId: 'pd_comm_101', question: 'The main goal of business writing is to...', options: ['Entertain', 'Communicate efficiently', 'Show off vocabulary', 'Confuse the reader'], correctIndex: 1),
      ],
    ),
    Lesson(
      id: 'c_l4',
      courseId: 'pd_comm_101',
      title: 'Nonverbal Communication',
      durationMinutes: 20,
      orderIndex: 3,
      content: 'More than 70% of communication is nonverbal. This includes body language, facial expressions, tone of voice, posture, and eye contact.\n\nKey aspects:\n• Posture: Stand tall to project confidence.\n• Tone: Ensure your tone matches your words.\n• Facial Expressions: A smile can disarm tension.\n• Gestures: Use open hand gestures; avoid crossing arms which can seem defensive.',
      quizzes: [
        Quiz(id: 'c_l4_q1', courseId: 'pd_comm_101', question: 'Roughly what percentage of communication is nonverbal?', options: ['10%', '30%', '50%', 'Over 70%'], correctIndex: 3),
        Quiz(id: 'c_l4_q2', courseId: 'pd_comm_101', question: 'Crossing your arms can signal what to the listener?', options: ['Openness', 'Defensiveness or disagreement', 'Joy', 'Confidence'], correctIndex: 1),
        Quiz(id: 'c_l4_q3', courseId: 'pd_comm_101', question: 'Which of the following is an example of nonverbal communication?', options: ['Sending an email', 'Tone of voice', 'Writing a report', 'Shouting a word'], correctIndex: 1),
        Quiz(id: 'c_l4_q4', courseId: 'pd_comm_101', question: 'How can you project confidence through posture?', options: ['Slouching', 'Standing tall with shoulders back', 'Leaning heavily on a desk', 'Hiding your hands'], correctIndex: 1),
        Quiz(id: 'c_l4_q5', courseId: 'pd_comm_101', question: 'Why is tone of voice important?', options: ['It is not important', 'It dictates how loudly you speak', 'It changes the meaning of the words being spoken', 'It makes you sound like a robot'], correctIndex: 2),
      ],
    ),
    Lesson(
      id: 'c_l5',
      courseId: 'pd_comm_101',
      title: 'Giving & Receiving Feedback',
      durationMinutes: 25,
      orderIndex: 4,
      content: 'Feedback is essential for growth, but it must be handled carefully.\n\nGiving Feedback:\n• Use the "Sandwich Method" (Positive, Constructive, Positive).\n• Be specific, not vague.\n• Focus on the behavior, not the person.\n\nReceiving Feedback:\n• Don\'t take it personally.\n• Listen actively without interrupting.\n• Ask clarifying questions.',
      quizzes: [
        Quiz(id: 'c_l5_q1', courseId: 'pd_comm_101', question: 'What is the "Sandwich Method" of feedback?', options: ['Eating lunch during feedback', 'Positive, Constructive, Positive', 'Negative, Negative, Negative', 'Only giving praise'], correctIndex: 1),
        Quiz(id: 'c_l5_q2', courseId: 'pd_comm_101', question: 'When giving constructive feedback, what should you focus on?', options: ['The person\'s character', 'The specific behavior or outcome', 'Their past mistakes', 'Their clothing'], correctIndex: 1),
        Quiz(id: 'c_l5_q3', courseId: 'pd_comm_101', question: 'What is a bad way to receive feedback?', options: ['Listening actively', 'Asking clarifying questions', 'Getting defensive and interrupting', 'Taking notes'], correctIndex: 2),
        Quiz(id: 'c_l5_q4', courseId: 'pd_comm_101', question: 'Why should feedback be specific?', options: ['To confuse the person', 'To make it actionable and clear', 'To make it sound smarter', 'To hurt feelings'], correctIndex: 1),
        Quiz(id: 'c_l5_q5', courseId: 'pd_comm_101', question: 'If you do not understand feedback, you should...', options: ['Ignore it', 'Quit your job', 'Argue back', 'Ask clarifying questions'], correctIndex: 3),
      ],
    ),
    Lesson(
      id: 'c_l6',
      courseId: 'pd_comm_101',
      title: 'Conflict Resolution',
      durationMinutes: 30,
      orderIndex: 5,
      content: 'Conflicts are inevitable in the workplace. Resolving them professionally is a key communication skill.\n\nSteps to resolve conflict:\n1. Stay calm and control your emotions.\n2. Address the issue privately.\n3. Actively listen to the other person\'s perspective.\n4. Find common ground.\n5. Agree on a solution moving forward.',
      quizzes: [
        Quiz(id: 'c_l6_q1', courseId: 'pd_comm_101', question: 'What is the first step in resolving a conflict?', options: ['Yell', 'Stay calm and control emotions', 'Blame the other person', 'Involve everyone in the office'], correctIndex: 1),
        Quiz(id: 'c_l6_q2', courseId: 'pd_comm_101', question: 'Where should you address a professional conflict?', options: ['In a public meeting', 'On social media', 'Privately', 'Through office gossip'], correctIndex: 2),
        Quiz(id: 'c_l6_q3', courseId: 'pd_comm_101', question: 'Why is active listening important in conflict resolution?', options: ['To find flaws in their argument', 'To understand their perspective', 'To prepare a comeback', 'To pretend you care'], correctIndex: 1),
        Quiz(id: 'c_l6_q4', courseId: 'pd_comm_101', question: 'What should be the ultimate goal of resolving a conflict?', options: ['Winning the argument', 'Proving you are right', 'Finding common ground and a solution', 'Getting the other person fired'], correctIndex: 2),
        Quiz(id: 'c_l6_q5', courseId: 'pd_comm_101', question: 'Are conflicts always entirely negative?', options: ['Yes', 'No, they can lead to better ideas if resolved well', 'Yes, they destroy teams', 'Yes, they should be avoided at all costs'], correctIndex: 1),
      ],
    ),
  ],
  quizzes: const [
    Quiz(id: 'c_final_q1', courseId: 'pd_comm_101', question: 'What is active listening?', options: ['Hearing words', 'Fully concentrating and understanding', 'Interrupting', 'Ignoring'], correctIndex: 1),
    Quiz(id: 'c_final_q2', courseId: 'pd_comm_101', question: 'What does crossed arms usually signify?', options: ['Openness', 'Defensiveness', 'Joy', 'Confidence'], correctIndex: 1),
    Quiz(id: 'c_final_q3', courseId: 'pd_comm_101', question: 'What is the sandwich method?', options: ['Positive, Constructive, Positive', 'Negative, Positive, Negative', 'All Positive', 'All Negative'], correctIndex: 0),
    Quiz(id: 'c_final_q4', courseId: 'pd_comm_101', question: 'Where should conflicts be resolved?', options: ['In public', 'Privately', 'Online', 'In the cafeteria'], correctIndex: 1),
    Quiz(id: 'c_final_q5', courseId: 'pd_comm_101', question: 'What is the goal of business writing?', options: ['To be poetic', 'To communicate efficiently', 'To be as long as possible', 'To confuse'], correctIndex: 1),
  ],
);
