export interface Quiz {
  id: string;
  courseId: string;
  question: string;
  options: string[];
  correctIndex: number;
}

export interface Lesson {
  id: string;
  courseId: string;
  title: string;
  content: string;
  durationMinutes: number;
  orderIndex: number;
  quizzes?: Quiz[];
  youtubeVideoId?: string;
  pdfUrl?: string;
}

export interface Course {
  id: string;
  title: string;
  description: string;
  category: string;
  color: number; // Stored as ARGB value (int)
  gradientEnd: number; // Stored as ARGB value (int)
  icon: {
    codePoint: number;
    fontFamily: string | null;
  };
  lessons: Lesson[];
  quizzes: Quiz[];
}
