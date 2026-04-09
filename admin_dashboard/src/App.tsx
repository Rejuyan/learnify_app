import React, { useState, useEffect } from 'react';
import { 
  auth, 
  db, 
  storage,
  signInWithEmailAndPassword, 
  signOut, 
  onAuthStateChanged 
} from './firebase';
import { 
  ref, 
  uploadBytesResumable, 
  getDownloadURL 
} from 'firebase/storage';
import { 
  collection, 
  doc, 
  setDoc, 
  deleteDoc, 
  onSnapshot 
} from 'firebase/firestore';
import { 
  BookOpen, 
  Plus, 
  Trash2, 
  Edit3, 
  Save, 
  LogOut, 
  Video, 
  Layers, 
  Lock, 
  Mail, 
  CheckCircle, 
  HelpCircle, 
  FolderPlus, 
  X, 
  ChevronRight,
  TrendingUp,
  FileText
} from 'lucide-react';
import type { Course, Lesson, Quiz } from './types';
import './App.css';

// Preset color options matching Flutter course designs (ARGB hex value equivalents)
const PRESET_COLORS = [
  { name: 'Teal/Cyan', color: 0xFF00BFA5, gradient: 0xFF00E5FF },
  { name: 'Blue/Flutter', color: 0xFF02569B, gradient: 0xFF0175C2 },
  { name: 'Purple/Indigo', color: 0xFF6C63FF, gradient: 0xFF4A3AFF },
  { name: 'Pink/Red', color: 0xFFF06292, gradient: 0xFFE91E63 },
  { name: 'Amber/Orange', color: 0xFFFFB74D, gradient: 0xFFFF9800 },
  { name: 'Green/Lime', color: 0xFF81C784, gradient: 0xFF4CAF50 },
  { name: 'Deep Purple', color: 0xFF7C4DFF, gradient: 0xFF3F51B5 }
];

// Preset Icon mappings (Flutter Icons codepoints)
const PRESET_ICONS = [
  { name: 'School / Academics', codePoint: 0xe559, nameKey: 'school' }, // school
  { name: 'Computer / Tech', codePoint: 0xe1b1, nameKey: 'computer' }, // computer
  { name: 'Book / Reading', codePoint: 0xe3e3, nameKey: 'book' }, // menu_book
  { name: 'Brush / Design', codePoint: 0xe115, nameKey: 'brush' }, // brush
  { name: 'Code / Dev', codePoint: 0xe18c, nameKey: 'code' }, // code
  { name: 'Business / Finance', codePoint: 0xe6e4, nameKey: 'business' } // monetization_on
];

function App() {
  const [user, setUser] = useState<any>(null);
  const [authLoading, setAuthLoading] = useState(true);
  
  // Auth Form State
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [authError, setAuthError] = useState('');
  const [loginSubmitting, setLoginSubmitting] = useState(false);

  // Firestore Data State
  const [courses, setCourses] = useState<Course[]>([]);
  const [dataLoading, setDataLoading] = useState(true);
  
  // Selection / Editing State
  const [selectedCourse, setSelectedCourse] = useState<Course | null>(null);
  const [activeTab, setActiveTab] = useState<'courses' | 'analytics'>('courses');

  // Modals state
  const [isCourseModalOpen, setIsCourseModalOpen] = useState(false);
  const [isLessonModalOpen, setIsLessonModalOpen] = useState(false);
  const [isQuizModalOpen, setIsQuizModalOpen] = useState(false);

  // Modal forms states
  const [newCourseId, setNewCourseId] = useState('');
  const [newCourseTitle, setNewCourseTitle] = useState('');
  const [newCourseDesc, setNewCourseDesc] = useState('');
  const [newCourseCat, setNewCourseCat] = useState('');
  const [newCourseColorIdx, setNewCourseColorIdx] = useState(0);
  const [newCourseIconIdx, setNewCourseIconIdx] = useState(0);

  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [newLessonTitle, setNewLessonTitle] = useState('');
  const [newLessonVideoId, setNewLessonVideoId] = useState('');
  const [newLessonMinutes, setNewLessonMinutes] = useState(15);
  const [newLessonContent, setNewLessonContent] = useState('');
  const [newLessonPdfUrl, setNewLessonPdfUrl] = useState('');
  const [uploadProgress, setUploadProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !selectedCourse) return;

    setIsUploading(true);
    setUploadProgress(0);

    const storageRef = ref(storage, `courses/${selectedCourse.id}/lessons/${Date.now()}_${file.name}`);
    const uploadTask = uploadBytesResumable(storageRef, file);

    uploadTask.on(
      'state_changed',
      (snapshot) => {
        const pct = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
        setUploadProgress(pct);
      },
      (error) => {
        alert('Upload failed: ' + error.message);
        setIsUploading(false);
      },
      async () => {
        const downloadUrl = await getDownloadURL(uploadTask.snapshot.ref);
        setNewLessonPdfUrl(downloadUrl);
        setIsUploading(false);
        setUploadProgress(0);
        alert('File uploaded and linked successfully!');
      }
    );
  };

  const [editingQuiz, setEditingQuiz] = useState<Quiz | null>(null);
  const [newQuizQuestion, setNewQuizQuestion] = useState('');
  const [newQuizOptions, setNewQuizOptions] = useState<string[]>(['', '', '', '']);
  const [newQuizCorrectIdx, setNewQuizCorrectIdx] = useState(0);

  // Lesson Quiz state
  const [isLessonQuizModalOpen, setIsLessonQuizModalOpen] = useState(false);
  const [selectedLessonForQuizzes, setSelectedLessonForQuizzes] = useState<Lesson | null>(null);
  const [editingLessonQuiz, setEditingLessonQuiz] = useState<Quiz | null>(null);
  const [isEditingLessonQuizForm, setIsEditingLessonQuizForm] = useState(false);
  const [newLessonQuizQuestion, setNewLessonQuizQuestion] = useState('');
  const [newLessonQuizOptions, setNewLessonQuizOptions] = useState<string[]>(['', '', '', '']);
  const [newLessonQuizCorrectIdx, setNewLessonQuizCorrectIdx] = useState(0);

  // Monitor Authentication state
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setAuthLoading(false);
    });
    return unsubscribe;
  }, []);

  // Listen to Firestore real-time updates
  useEffect(() => {
    if (!user) return;
    
    setDataLoading(true);
    const unsubscribe = onSnapshot(collection(db, 'courses'), (snapshot) => {
      const coursesData: Course[] = [];
      snapshot.forEach((doc) => {
        coursesData.push({ id: doc.id, ...doc.data() } as Course);
      });
      setCourses(coursesData);
      
      // Auto-update selected course in view if it gets modified
      if (selectedCourse) {
        const updated = coursesData.find((c) => c.id === selectedCourse.id);
        if (updated) setSelectedCourse(updated);
      }
      
      setDataLoading(false);
    }, (error) => {
      console.error("Firestore listening error: ", error);
      setDataLoading(false);
    });

    return unsubscribe;
  }, [user]);

  // Login handler
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError('');
    setLoginSubmitting(true);
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err: any) {
      console.error(err);
      setAuthError(err.message || 'Incorrect email or password.');
    } finally {
      setLoginSubmitting(false);
    }
  };

  // Sign out handler
  const handleSignOut = () => {
    signOut(auth);
    setSelectedCourse(null);
  };

  // ─── Course Management operations ─────────────────────────────
  
  const handleCreateCourse = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCourseId || !newCourseTitle) return;

    const formattedId = newCourseId.trim().toLowerCase().replaceAll(' ', '_');
    const colorObj = PRESET_COLORS[newCourseColorIdx];
    const iconObj = PRESET_ICONS[newCourseIconIdx];

    const newCourse: Course = {
      id: formattedId,
      title: newCourseTitle,
      description: newCourseDesc,
      category: newCourseCat || 'General',
      color: colorObj.color,
      gradientEnd: colorObj.gradient,
      icon: {
        codePoint: iconObj.codePoint,
        fontFamily: 'MaterialIcons'
      },
      lessons: [],
      quizzes: []
    };

    try {
      await setDoc(doc(db, 'courses', formattedId), newCourse);
      setIsCourseModalOpen(false);
      
      // Clear forms
      setNewCourseId('');
      setNewCourseTitle('');
      setNewCourseDesc('');
      setNewCourseCat('');
      
      // Auto select the new course
      setSelectedCourse(newCourse);
    } catch (err) {
      alert('Error creating course: ' + err);
    }
  };

  const handleUpdateCourseDetails = async () => {
    if (!selectedCourse) return;
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), selectedCourse);
      alert('Course details saved successfully!');
    } catch (err) {
      alert('Error updating details: ' + err);
    }
  };

  const handleDeleteCourse = async (courseId: string) => {
    if (!window.confirm('Are you absolutely sure you want to delete this course? All associated lessons and quizzes will be deleted permanently.')) return;
    try {
      await deleteDoc(doc(db, 'courses', courseId));
      if (selectedCourse?.id === courseId) {
        setSelectedCourse(null);
      }
    } catch (err) {
      alert('Error deleting course: ' + err);
    }
  };

  // ─── Lesson Management operations ─────────────────────────────

  const openLessonModal = (lesson?: Lesson) => {
    setUploadProgress(0);
    setIsUploading(false);
    if (lesson) {
      setEditingLesson(lesson);
      setNewLessonTitle(lesson.title);
      setNewLessonVideoId(lesson.youtubeVideoId || '');
      setNewLessonMinutes(lesson.durationMinutes);
      setNewLessonContent(lesson.content);
      setNewLessonPdfUrl(lesson.pdfUrl || '');
    } else {
      setEditingLesson(null);
      setNewLessonTitle('');
      setNewLessonVideoId('');
      setNewLessonMinutes(15);
      setNewLessonContent('');
      setNewLessonPdfUrl('');
    }
    setIsLessonModalOpen(true);
  };

  const handleSaveLesson = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCourse || !newLessonTitle) return;

    let updatedLessons = [...selectedCourse.lessons];

    if (editingLesson) {
      // Edit mode
      updatedLessons = updatedLessons.map((l) => 
        l.id === editingLesson.id 
          ? { 
              ...l, 
              title: newLessonTitle, 
              youtubeVideoId: newLessonVideoId || undefined,
              durationMinutes: Number(newLessonMinutes),
              content: newLessonContent,
              pdfUrl: newLessonPdfUrl || undefined
            }
          : l
      );
    } else {
      // Create mode
      const newId = `${selectedCourse.id}_l${updatedLessons.length + 1}`;
      const newLesson: Lesson = {
        id: newId,
        courseId: selectedCourse.id,
        title: newLessonTitle,
        content: newLessonContent,
        durationMinutes: Number(newLessonMinutes),
        orderIndex: updatedLessons.length,
        youtubeVideoId: newLessonVideoId || undefined,
        pdfUrl: newLessonPdfUrl || undefined
      };
      updatedLessons.push(newLesson);
    }

    const updatedCourse = { ...selectedCourse, lessons: updatedLessons };
    
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), updatedCourse);
      setSelectedCourse(updatedCourse);
      setIsLessonModalOpen(false);
    } catch (err) {
      alert('Error saving lesson: ' + err);
    }
  };

  const handleDeleteLesson = async (lessonId: string) => {
    if (!selectedCourse || !window.confirm('Delete this lesson?')) return;
    
    const updatedLessons = selectedCourse.lessons
      .filter((l) => l.id !== lessonId)
      .map((l, index) => ({ ...l, orderIndex: index })); // Re-order indexes

    const updatedCourse = { ...selectedCourse, lessons: updatedLessons };
    
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), updatedCourse);
      setSelectedCourse(updatedCourse);
    } catch (err) {
      alert('Error deleting lesson: ' + err);
    }
  };

  // ─── Quiz Management operations ───────────────────────────────

  const openQuizModal = (quiz?: Quiz) => {
    if (quiz) {
      setEditingQuiz(quiz);
      setNewQuizQuestion(quiz.question);
      setNewQuizOptions([...quiz.options]);
      setNewQuizCorrectIdx(quiz.correctIndex);
    } else {
      setEditingQuiz(null);
      setNewQuizQuestion('');
      setNewQuizOptions(['', '', '', '']);
      setNewQuizCorrectIdx(0);
    }
    setIsQuizModalOpen(true);
  };

  const handleSaveQuiz = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCourse || !newQuizQuestion) return;

    let updatedQuizzes = [...selectedCourse.quizzes];

    if (editingQuiz) {
      // Edit mode
      updatedQuizzes = updatedQuizzes.map((q) => 
        q.id === editingQuiz.id 
          ? { 
              ...q, 
              question: newQuizQuestion, 
              options: newQuizOptions.filter(o => o.trim() !== ''),
              correctIndex: newQuizCorrectIdx
            }
          : q
      );
    } else {
      // Create mode
      const newId = `${selectedCourse.id}_q${updatedQuizzes.length + 1}`;
      const newQuiz: Quiz = {
        id: newId,
        courseId: selectedCourse.id,
        question: newQuizQuestion,
        options: newQuizOptions.filter(o => o.trim() !== ''),
        correctIndex: newQuizCorrectIdx
      };
      updatedQuizzes.push(newQuiz);
    }

    const updatedCourse = { ...selectedCourse, quizzes: updatedQuizzes };
    
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), updatedCourse);
      setSelectedCourse(updatedCourse);
      setIsQuizModalOpen(false);
    } catch (err) {
      alert('Error saving quiz: ' + err);
    }
  };

  const handleDeleteQuiz = async (quizId: string) => {
    if (!selectedCourse || !window.confirm('Delete this quiz question?')) return;
    
    const updatedQuizzes = selectedCourse.quizzes.filter((q) => q.id !== quizId);
    const updatedCourse = { ...selectedCourse, quizzes: updatedQuizzes };
    
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), updatedCourse);
      setSelectedCourse(updatedCourse);
    } catch (err) {
      alert('Error deleting quiz: ' + err);
    }
  };

  const openLessonQuizManager = (lesson: Lesson) => {
    setSelectedLessonForQuizzes(lesson);
    setIsLessonQuizModalOpen(true);
    setIsEditingLessonQuizForm(false);
    setEditingLessonQuiz(null);
  };

  const openLessonQuizForm = (quiz?: Quiz) => {
    if (quiz) {
      setEditingLessonQuiz(quiz);
      setNewLessonQuizQuestion(quiz.question);
      setNewLessonQuizOptions([...quiz.options]);
      setNewLessonQuizCorrectIdx(quiz.correctIndex);
    } else {
      setEditingLessonQuiz(null);
      setNewLessonQuizQuestion('');
      setNewLessonQuizOptions(['', '', '', '']);
      setNewLessonQuizCorrectIdx(0);
    }
    setIsEditingLessonQuizForm(true);
  };

  const handleSaveLessonQuiz = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCourse || !selectedLessonForQuizzes || !newLessonQuizQuestion) return;

    let lessonQuizzes = [...(selectedLessonForQuizzes.quizzes || [])];

    if (editingLessonQuiz) {
      // Edit mode
      lessonQuizzes = lessonQuizzes.map((q) => 
        q.id === editingLessonQuiz.id 
          ? { 
              ...q, 
              question: newLessonQuizQuestion, 
              options: newLessonQuizOptions.filter(o => o.trim() !== ''),
              correctIndex: newLessonQuizCorrectIdx
            }
          : q
      );
    } else {
      // Create mode
      const newId = `${selectedLessonForQuizzes.id}_q${lessonQuizzes.length + 1}`;
      const newQuiz: Quiz = {
        id: newId,
        courseId: selectedCourse.id,
        question: newLessonQuizQuestion,
        options: newLessonQuizOptions.filter(o => o.trim() !== ''),
        correctIndex: newLessonQuizCorrectIdx
      };
      lessonQuizzes.push(newQuiz);
    }

    const updatedLesson = { ...selectedLessonForQuizzes, quizzes: lessonQuizzes };
    const updatedLessons = selectedCourse.lessons.map((l) => 
      l.id === selectedLessonForQuizzes.id ? updatedLesson : l
    );
    const updatedCourse = { ...selectedCourse, lessons: updatedLessons };
    
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), updatedCourse);
      setSelectedCourse(updatedCourse);
      setSelectedLessonForQuizzes(updatedLesson);
      setIsEditingLessonQuizForm(false);
    } catch (err) {
      alert('Error saving lesson quiz: ' + err);
    }
  };

  const handleDeleteLessonQuiz = async (quizId: string) => {
    if (!selectedCourse || !selectedLessonForQuizzes || !window.confirm('Delete this quiz question?')) return;
    
    const lessonQuizzes = (selectedLessonForQuizzes.quizzes || []).filter((q) => q.id !== quizId);
    const updatedLesson = { ...selectedLessonForQuizzes, quizzes: lessonQuizzes };
    const updatedLessons = selectedCourse.lessons.map((l) => 
      l.id === selectedLessonForQuizzes.id ? updatedLesson : l
    );
    const updatedCourse = { ...selectedCourse, lessons: updatedLessons };
    
    try {
      await setDoc(doc(db, 'courses', selectedCourse.id), updatedCourse);
      setSelectedCourse(updatedCourse);
      setSelectedLessonForQuizzes(updatedLesson);
    } catch (err) {
      alert('Error deleting lesson quiz: ' + err);
    }
  };

  const updateQuizOption = (index: number, val: string) => {
    const updated = [...newQuizOptions];
    updated[index] = val;
    setNewQuizOptions(updated);
  };

  const updateLessonQuizOption = (index: number, val: string) => {
    const updated = [...newLessonQuizOptions];
    updated[index] = val;
    setNewLessonQuizOptions(updated);
  };

  // Convert Flutter Decimal Color to hex code
  const getHexColor = (value: number) => {
    const argb = value.toString(16).toUpperCase().padStart(8, '0');
    return `#${argb.substring(2)}`; // strip out alpha channel
  };

  // ─── Rendering helpers ─────────────────────────────────────────

  if (authLoading) {
    return (
      <div className="page-loader">
        <div className="spinner"></div>
        <p>Loading Learnify Session...</p>
      </div>
    );
  }

  // ─── Login Screen (If Not Authenticated) ───────────────────────
  if (!user) {
    return (
      <div className="app-container">
        <div className="glow-orb-1"></div>
        <div className="glow-orb-2"></div>
        <div className="auth-wrapper">
          <form className="auth-card" onSubmit={handleLogin}>
            <div className="auth-header">
              <h1>Learnify Admin</h1>
              <p>Manage courses, lectures, quizzes, and digital assets.</p>
            </div>
            
            {authError && (
              <div className="alert-error">
                <X size={16} />
                <span>{authError}</span>
              </div>
            )}

            <div className="form-group">
              <label>Email Address</label>
              <div style={{ position: 'relative' }}>
                <Mail size={18} style={{ position: 'absolute', left: '16px', top: '15px', color: 'var(--text-secondary)' }} />
                <input 
                  type="email" 
                  className="input-glass" 
                  placeholder="admin@learnify.com" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  style={{ paddingLeft: '3rem' }}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label>Password</label>
              <div style={{ position: 'relative' }}>
                <Lock size={18} style={{ position: 'absolute', left: '16px', top: '15px', color: 'var(--text-secondary)' }} />
                <input 
                  type="password" 
                  className="input-glass" 
                  placeholder="••••••••" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  style={{ paddingLeft: '3rem' }}
                  required
                />
              </div>
            </div>

            <button type="submit" className="btn-glowing" disabled={loginSubmitting}>
              {loginSubmitting ? 'Verifying Credentials...' : 'Sign In as Administrator'}
              <ChevronRight size={18} />
            </button>
          </form>
        </div>
      </div>
    );
  }

  // ─── Admin Dashboard Shell (If Authenticated) ─────────────────
  
  // Aggregate Stats
  const totalLessonsCount = courses.reduce((acc, c) => acc + (c.lessons?.length || 0), 0);
  const totalQuizzesCount = courses.reduce((acc, c) => acc + (c.quizzes?.length || 0), 0);

  return (
    <div className="app-container">
      <div className="glow-orb-1"></div>
      <div className="glow-orb-2"></div>

      {/* Navigation Header */}
      <header className="header-glass">
        <div className="brand">
          <BookOpen className="brand-logo" size={24} style={{ color: 'var(--accent-purple)' }} />
          <span className="brand-logo">LEARNIFY</span>
          <span className="brand-badge">ADMIN CONTROL</span>
        </div>
        <div className="user-controls">
          <span className="user-email">{user.email}</span>
          <button className="btn-secondary-glass" onClick={handleSignOut} style={{ padding: '0.5rem 1rem' }}>
            <LogOut size={16} />
            Sign Out
          </button>
        </div>
      </header>

      {/* Main Workspace Workspace */}
      <main className="workspace-wrapper">
        
        {/* Navigation Tabs and Top controls */}
        <div className="nav-row">
          <div className="tabs-glass">
            <button 
              className={`tab-btn ${activeTab === 'courses' ? 'active' : ''}`}
              onClick={() => { setActiveTab('courses'); setSelectedCourse(null); }}
            >
              <Layers size={16} />
              Course Dashboard
            </button>
            <button 
              className={`tab-btn ${activeTab === 'analytics' ? 'active' : ''}`}
              onClick={() => setActiveTab('analytics')}
            >
              <TrendingUp size={16} />
              Platform Stats
            </button>
          </div>
          
          {activeTab === 'courses' && !selectedCourse && (
            <button className="btn-glowing" onClick={() => setIsCourseModalOpen(true)}>
              <Plus size={18} />
              Create New Course
            </button>
          )}
        </div>

        {/* Dynamic content panels */}
        {dataLoading ? (
          <div className="page-loader">
            <div className="spinner"></div>
            <p>Syncing Cloud Database...</p>
          </div>
        ) : activeTab === 'analytics' ? (
          /* ANALYTICS VIEW */
          <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
            <div className="stats-grid">
              <div className="stat-card-glass">
                <div className="stat-icon-box purple">
                  <Layers size={24} />
                </div>
                <div className="stat-info">
                  <h3>Active Courses</h3>
                  <p>{courses.length}</p>
                </div>
              </div>
              
              <div className="stat-card-glass">
                <div className="stat-icon-box cyan">
                  <Video size={24} />
                </div>
                <div className="stat-info">
                  <h3>Video Lessons</h3>
                  <p>{totalLessonsCount}</p>
                </div>
              </div>

              <div className="stat-card-glass">
                <div className="stat-icon-box pink">
                  <HelpCircle size={24} />
                </div>
                <div className="stat-info">
                  <h3>Quiz Questions</h3>
                  <p>{totalQuizzesCount}</p>
                </div>
              </div>
            </div>

            <div className="editor-main-card">
              <h2 style={{ fontFamily: 'var(--font-heading)', fontWeight: 700 }}>Course Breakdown</h2>
              <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '1.5rem', color: 'var(--text-secondary)' }}>
                <thead>
                  <tr style={{ textAlign: 'left', borderBottom: '1px solid var(--glass-border)', paddingBottom: '1rem' }}>
                    <th style={{ padding: '1rem 0' }}>Course Title</th>
                    <th>Category</th>
                    <th>Lessons</th>
                    <th>Quizzes</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {courses.map((course) => (
                    <tr key={course.id} style={{ borderBottom: '1px solid rgba(255,255,255,0.03)' }}>
                      <td style={{ padding: '1.25rem 0', fontWeight: 600, color: '#fff' }}>{course.title}</td>
                      <td>{course.category}</td>
                      <td>{course.lessons?.length || 0} lectures</td>
                      <td>{course.quizzes?.length || 0} questions</td>
                      <td>
                        <span style={{ 
                          color: (course.lessons?.length || 0) > 0 ? 'var(--success)' : 'var(--accent-pink)',
                          fontSize: '0.8rem',
                          fontWeight: '600'
                        }}>
                          {(course.lessons?.length || 0) > 0 ? '● Active' : '○ Draft (No Lessons)'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        ) : (
          /* COURSES VIEW */
          <div>
            {!selectedCourse ? (
              /* COURSE SELECTION GRID */
              <div className="course-grid">
                {courses.map((course) => {
                  const hexColor = getHexColor(course.color);
                  return (
                    <div 
                      key={course.id} 
                      className="course-card-glass"
                      onClick={() => setSelectedCourse(course)}
                    >
                      <div className="course-card-color-strip" style={{ backgroundColor: hexColor }}></div>
                      <div className="course-card-header">
                        <div className="course-card-icon" style={{ backgroundColor: hexColor }}>
                          <BookOpen size={20} />
                        </div>
                        <span className="course-category">{course.category}</span>
                      </div>
                      
                      <h3 className="course-title">{course.title}</h3>
                      <p className="course-description">{course.description}</p>
                      
                      <div className="course-card-footer">
                        <span className="course-meta-text">
                          <Layers size={14} />
                          {course.lessons?.length || 0} Lectures
                        </span>
                        <span className="course-meta-text">
                          <HelpCircle size={14} />
                          {course.quizzes?.length || 0} Questions
                        </span>
                      </div>

                      <button 
                        className="btn-icon-glass danger"
                        onClick={(e) => { e.stopPropagation(); handleDeleteCourse(course.id); }}
                        style={{ position: 'absolute', right: '16px', top: '16px', width: '32px', height: '32px' }}
                        title="Delete Course"
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  );
                })}
              </div>
            ) : (
              /* COURSE EDITOR split screen layout */
              <div className="editor-layout">
                
                {/* Side parameters editor panel */}
                <aside className="editor-sidebar">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <h3 style={{ fontFamily: 'var(--font-heading)', fontWeight: 700 }}>Course Details</h3>
                    <button className="btn-icon-glass" onClick={() => setSelectedCourse(null)} title="Close Editor">
                      <X size={16} />
                    </button>
                  </div>
                  
                  <div className="form-group">
                    <label>Course Title</label>
                    <input 
                      type="text" 
                      className="input-glass"
                      value={selectedCourse.title}
                      onChange={(e) => setSelectedCourse({ ...selectedCourse, title: e.target.value })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Category</label>
                    <input 
                      type="text" 
                      className="input-glass"
                      value={selectedCourse.category}
                      onChange={(e) => setSelectedCourse({ ...selectedCourse, category: e.target.value })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Description</label>
                    <textarea 
                      className="input-glass"
                      rows={4}
                      value={selectedCourse.description}
                      onChange={(e) => setSelectedCourse({ ...selectedCourse, description: e.target.value })}
                      style={{ resize: 'none' }}
                    />
                  </div>

                  <button className="btn-glowing" onClick={handleUpdateCourseDetails}>
                    <Save size={16} />
                    Save Course Details
                  </button>
                </aside>

                {/* Main Content management view (Lessons & Quizzes) */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
                  
                  {/* LESSONS MANAGER */}
                  <div className="editor-main-card">
                    <div className="editor-section-header">
                      <h2>Syllabus & Lessons ({selectedCourse.lessons?.length || 0})</h2>
                      <button className="btn-secondary-glass" onClick={() => openLessonModal()}>
                        <Plus size={16} />
                        Add Lecture
                      </button>
                    </div>

                    {selectedCourse.lessons?.length === 0 ? (
                      <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', textAlign: 'center', padding: '2rem 0' }}>
                        No lectures added yet. Get started by adding a lesson!
                      </p>
                    ) : (
                      <div className="nested-manager-list">
                        {selectedCourse.lessons
                          .sort((a, b) => a.orderIndex - b.orderIndex)
                          .map((lesson) => (
                            <div key={lesson.id} className="nested-item-row">
                              <div className="nested-item-info">
                                <div className="nested-item-order">{lesson.orderIndex + 1}</div>
                                <div>
                                  <div className="nested-item-title">{lesson.title}</div>
                                  <div className="nested-item-subtitle" style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
                                    <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                                      <Video size={12} />
                                      YouTube: {lesson.youtubeVideoId || 'None'}
                                    </span>
                                    <span>● {lesson.durationMinutes} minutes</span>
                                    <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem', color: 'var(--accent-cyan)' }}>
                                      <HelpCircle size={12} />
                                      {(lesson.quizzes?.length || 0)} Quizzes
                                    </span>
                                  </div>
                                </div>
                              </div>
                              <div className="nested-item-actions">
                                <button className="btn-icon-glass" onClick={() => openLessonQuizManager(lesson)} title="Manage Lesson Quizzes" style={{ color: 'var(--accent-cyan)' }}>
                                  <HelpCircle size={14} />
                                </button>
                                <button className="btn-icon-glass" onClick={() => openLessonModal(lesson)} title="Edit Lesson">
                                  <Edit3 size={14} />
                                </button>
                                <button className="btn-icon-glass danger" onClick={() => handleDeleteLesson(lesson.id)} title="Delete Lesson">
                                  <Trash2 size={14} />
                                </button>
                              </div>
                            </div>
                          ))}
                      </div>
                    )}
                  </div>

                  {/* QUIZ MANAGER */}
                  <div className="editor-main-card">
                    <div className="editor-section-header">
                      <h2>Course final Quiz ({selectedCourse.quizzes?.length || 0} questions)</h2>
                      <button className="btn-secondary-glass" onClick={() => openQuizModal()}>
                        <Plus size={16} />
                        Add Question
                      </button>
                    </div>

                    {selectedCourse.quizzes?.length === 0 ? (
                      <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', textAlign: 'center', padding: '2rem 0' }}>
                        No quiz questions created yet. Add questions to let students test their learning!
                      </p>
                    ) : (
                      <div className="nested-manager-list">
                        {selectedCourse.quizzes.map((quiz, index) => (
                          <div key={quiz.id} className="nested-item-row">
                            <div className="nested-item-info">
                              <div className="nested-item-order">{index + 1}</div>
                              <div>
                                <div className="nested-item-title">{quiz.question}</div>
                                <div className="nested-item-subtitle" style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', marginTop: '0.35rem' }}>
                                  {quiz.options.map((option, oIdx) => (
                                    <span 
                                      key={oIdx} 
                                      style={{ 
                                        padding: '0.15rem 0.5rem',
                                        borderRadius: '4px',
                                        fontSize: '0.75rem',
                                        background: oIdx === quiz.correctIndex ? 'rgba(0, 230, 118, 0.12)' : 'rgba(255,255,255,0.03)',
                                        border: oIdx === quiz.correctIndex ? '1px solid rgba(0, 230, 118, 0.3)' : '1px solid var(--glass-border)',
                                        color: oIdx === quiz.correctIndex ? 'var(--success)' : 'var(--text-secondary)'
                                      }}
                                    >
                                      {option}
                                    </span>
                                  ))}
                                </div>
                              </div>
                            </div>
                            <div className="nested-item-actions">
                              <button className="btn-icon-glass" onClick={() => openQuizModal(quiz)} title="Edit Question">
                                <Edit3 size={14} />
                              </button>
                              <button className="btn-icon-glass danger" onClick={() => handleDeleteQuiz(quiz.id)} title="Delete Question">
                                <Trash2 size={14} />
                              </button>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </main>

      {/* ─── MODAL: CREATE COURSE ───────────────────────────────────── */}
      {isCourseModalOpen && (
        <div className="modal-overlay">
          <form className="modal-content" onSubmit={handleCreateCourse}>
            <div className="modal-header">
              <h3>Create New Course</h3>
              <button type="button" className="btn-icon-glass" onClick={() => setIsCourseModalOpen(false)}>
                <X size={16} />
              </button>
            </div>

            <div className="form-grid-2">
              <div className="form-group">
                <label>Unique Course ID (e.g. basic_computing)</label>
                <input 
                  type="text" 
                  className="input-glass"
                  placeholder="basic_computing" 
                  value={newCourseId}
                  onChange={(e) => setNewCourseId(e.target.value)}
                  required
                />
              </div>
              <div className="form-group">
                <label>Course Title</label>
                <input 
                  type="text" 
                  className="input-glass"
                  placeholder="Basic Computing Essentials" 
                  value={newCourseTitle}
                  onChange={(e) => setNewCourseTitle(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="form-grid-2">
              <div className="form-group">
                <label>Category</label>
                <input 
                  type="text" 
                  className="input-glass"
                  placeholder="Technology" 
                  value={newCourseCat}
                  onChange={(e) => setNewCourseCat(e.target.value)}
                />
              </div>
              <div className="form-group">
                <label>Course Icon Style</label>
                <select 
                  className="input-glass"
                  value={newCourseIconIdx}
                  onChange={(e) => setNewCourseIconIdx(Number(e.target.value))}
                  style={{ background: 'var(--bg-primary)' }}
                >
                  {PRESET_ICONS.map((icon, idx) => (
                    <option key={idx} value={idx}>{icon.name}</option>
                  ))}
                </select>
              </div>
            </div>

            <div className="form-group">
              <label>Course Description</label>
              <textarea 
                className="input-glass"
                placeholder="Give a short summary of what students will master..."
                rows={3}
                value={newCourseDesc}
                onChange={(e) => setNewCourseDesc(e.target.value)}
                style={{ resize: 'none' }}
              />
            </div>

            <div className="form-group">
              <label>Harmonious Theme Color Palette</label>
              <div className="color-picker-row">
                {PRESET_COLORS.map((c, idx) => (
                  <div 
                    key={idx}
                    className={`color-dot-choice ${newCourseColorIdx === idx ? 'selected' : ''}`}
                    style={{ background: `linear-gradient(135deg, ${getHexColor(c.color)} 0%, ${getHexColor(c.gradient)} 100%)` }}
                    onClick={() => setNewCourseColorIdx(idx)}
                    title={c.name}
                  />
                ))}
              </div>
            </div>

            <div className="modal-footer">
              <button type="button" className="btn-secondary-glass" onClick={() => setIsCourseModalOpen(false)}>
                Cancel
              </button>
              <button type="submit" className="btn-glowing">
                <FolderPlus size={16} />
                Bootstrap Course
              </button>
            </div>
          </form>
        </div>
      )}

      {/* ─── MODAL: LESSON EDITOR ────────────────────────────────────── */}
      {isLessonModalOpen && (
        <div className="modal-overlay">
          <form className="modal-content" onSubmit={handleSaveLesson}>
            <div className="modal-header">
              <h3>{editingLesson ? 'Edit Video Lecture' : 'Add New Lecture'}</h3>
              <button type="button" className="btn-icon-glass" onClick={() => setIsLessonModalOpen(false)}>
                <X size={16} />
              </button>
            </div>

            <div className="form-group">
              <label>Lecture Title</label>
              <input 
                type="text" 
                className="input-glass"
                placeholder="Introduction to State Management"
                value={newLessonTitle}
                onChange={(e) => setNewLessonTitle(e.target.value)}
                required
              />
            </div>

            <div className="form-grid-2">
              <div className="form-group">
                <label>YouTube Video ID (Optional)</label>
                <input 
                  type="text" 
                  className="input-glass"
                  placeholder="dQw4w9WgXcQ"
                  value={newLessonVideoId}
                  onChange={(e) => setNewLessonVideoId(e.target.value)}
                />
              </div>
              <div className="form-group">
                <label>Duration (Minutes)</label>
                <input 
                  type="number" 
                  className="input-glass"
                  value={newLessonMinutes}
                  onChange={(e) => setNewLessonMinutes(Number(e.target.value))}
                  min={1}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label>Study Material & Syllabus Notes</label>
              <textarea 
                className="input-glass"
                placeholder="Provide detailed written information, links, and text resources..."
                rows={8}
                value={newLessonContent}
                onChange={(e) => setNewLessonContent(e.target.value)}
              />
            </div>

            <div className="form-group" style={{ border: '1px dashed var(--glass-border)', padding: '1rem', borderRadius: '10px', marginTop: '0.5rem' }}>
              <label>Upload Study PDF / Book / Slides</label>
              <div style={{ display: 'flex', gap: '1rem', marginTop: '0.5rem', alignItems: 'center' }}>
                <input 
                  type="file" 
                  accept=".pdf,.docx,.epub,.ppt,.pptx"
                  onChange={handleFileUpload}
                  style={{ display: 'none' }}
                  id="pdf-file-selector"
                  disabled={isUploading}
                />
                <label htmlFor="pdf-file-selector" className="btn-secondary-glass" style={{ cursor: 'pointer', margin: 0 }}>
                  <FileText size={16} />
                  Choose PDF Book / Slides
                </label>
                {newLessonPdfUrl && (
                  <span style={{ fontSize: '0.8rem', color: 'var(--success)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                    <CheckCircle size={14} />
                    Linked: {newLessonPdfUrl.split('/').pop()?.split('_').slice(1).join('_').substring(0, 20) || 'notes.pdf'}
                  </span>
                )}
              </div>
              
              {isUploading && (
                <div style={{ marginTop: '0.75rem' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                    <span>Uploading file...</span>
                    <span>{uploadProgress}%</span>
                  </div>
                  <div style={{ height: '3px', background: 'rgba(255,255,255,0.05)', borderRadius: '2px', overflow: 'hidden', marginTop: '0.25rem' }}>
                    <div style={{ width: `${uploadProgress}%`, height: '100%', background: 'var(--accent-cyan)' }}></div>
                  </div>
                </div>
              )}
            </div>

            <div className="modal-footer">
              <button type="button" className="btn-secondary-glass" onClick={() => setIsLessonModalOpen(false)}>
                Cancel
              </button>
              <button type="submit" className="btn-glowing">
                <CheckCircle size={16} />
                Save Lecture
              </button>
            </div>
          </form>
        </div>
      )}

      {/* ─── MODAL: QUIZ EDITOR ──────────────────────────────────────── */}
      {isQuizModalOpen && (
        <div className="modal-overlay">
          <form className="modal-content" onSubmit={handleSaveQuiz}>
            <div className="modal-header">
              <h3>{editingQuiz ? 'Edit Quiz Question' : 'Add Quiz Question'}</h3>
              <button type="button" className="btn-icon-glass" onClick={() => setIsQuizModalOpen(false)}>
                <X size={16} />
              </button>
            </div>

            <div className="form-group">
              <label>Question Text</label>
              <input 
                type="text" 
                className="input-glass"
                placeholder="What is the time complexity of binary search?"
                value={newQuizQuestion}
                onChange={(e) => setNewQuizQuestion(e.target.value)}
                required
              />
            </div>

            <div className="form-group">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                <label>Multiple Choice Options</label>
                <span style={{ fontSize: '0.75rem', color: 'var(--accent-cyan)' }}>Select radio option for correct answer</span>
              </div>
              
              <div className="quiz-options-list">
                {newQuizOptions.map((opt, oIdx) => (
                  <div key={oIdx} className="quiz-option-builder-row">
                    <input 
                      type="radio" 
                      name="correct-quiz-idx"
                      className="radio-glass"
                      checked={newQuizCorrectIdx === oIdx}
                      onChange={() => setNewQuizCorrectIdx(oIdx)}
                      title="Set as correct answer"
                    />
                    <input 
                      type="text" 
                      className="input-glass"
                      placeholder={`Option ${oIdx + 1}`}
                      value={opt}
                      onChange={(e) => updateQuizOption(oIdx, e.target.value)}
                      required
                    />
                  </div>
                ))}
              </div>
            </div>

            <div className="modal-footer">
              <button type="button" className="btn-secondary-glass" onClick={() => setIsQuizModalOpen(false)}>
                Cancel
              </button>
              <button type="submit" className="btn-glowing">
                <CheckCircle size={16} />
                Save Question
              </button>
            </div>
          </form>
        </div>
      )}
      {/* ─── MODAL: LESSON QUIZ MANAGER ───────────────────────────────── */}
      {isLessonQuizModalOpen && selectedLessonForQuizzes && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '650px' }}>
            <div className="modal-header">
              <div>
                <span className="course-category" style={{ fontSize: '0.75rem', marginBottom: '0.25rem', display: 'block' }}>
                  Lesson Quiz Manager
                </span>
                <h3 style={{ margin: 0 }}>{selectedLessonForQuizzes.title}</h3>
              </div>
              <button type="button" className="btn-icon-glass" onClick={() => setIsLessonQuizModalOpen(false)}>
                <X size={16} />
              </button>
            </div>

            {isEditingLessonQuizForm ? (
              /* QUIZ FORM */
              <form onSubmit={handleSaveLessonQuiz}>
                <div className="form-group">
                  <label>Question Text</label>
                  <input 
                    type="text" 
                    className="input-glass"
                    placeholder="What is the output of this code snippet?"
                    value={newLessonQuizQuestion}
                    onChange={(e) => setNewLessonQuizQuestion(e.target.value)}
                    required
                    autoFocus
                  />
                </div>

                <div className="form-group">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                    <label>Multiple Choice Options</label>
                    <span style={{ fontSize: '0.75rem', color: 'var(--accent-cyan)' }}>Select radio option for correct answer</span>
                  </div>
                  
                  <div className="quiz-options-list">
                    {newLessonQuizOptions.map((opt, oIdx) => (
                      <div key={oIdx} className="quiz-option-builder-row">
                        <input 
                          type="radio" 
                          name="correct-lesson-quiz-idx"
                          className="radio-glass"
                          checked={newLessonQuizCorrectIdx === oIdx}
                          onChange={() => setNewLessonQuizCorrectIdx(oIdx)}
                          title="Set as correct answer"
                        />
                        <input 
                          type="text" 
                          className="input-glass"
                          placeholder={`Option ${oIdx + 1}`}
                          value={opt}
                          onChange={(e) => updateLessonQuizOption(oIdx, e.target.value)}
                          required
                        />
                      </div>
                    ))}
                  </div>
                </div>

                <div className="modal-footer" style={{ padding: '1rem 0 0 0', borderTop: '1px solid var(--glass-border)', marginTop: '1.5rem' }}>
                  <button type="button" className="btn-secondary-glass" onClick={() => setIsEditingLessonQuizForm(false)}>
                    Cancel
                  </button>
                  <button type="submit" className="btn-glowing">
                    <CheckCircle size={16} />
                    {editingLessonQuiz ? 'Update Question' : 'Save Question'}
                  </button>
                </div>
              </form>
            ) : (
              /* QUIZ LIST */
              <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <p style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                    Manage quizzes that students must pass to complete this lesson.
                  </p>
                  <button className="btn-secondary-glass" onClick={() => openLessonQuizForm()} style={{ padding: '0.4rem 0.8rem', fontSize: '0.8rem' }}>
                    <Plus size={14} />
                    Add Question
                  </button>
                </div>

                {(!selectedLessonForQuizzes.quizzes || selectedLessonForQuizzes.quizzes.length === 0) ? (
                  <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', textAlign: 'center', padding: '2rem 0', background: 'rgba(255,255,255,0.01)', borderRadius: '10px', border: '1px dashed var(--glass-border)' }}>
                    No quiz questions created for this lesson yet.
                  </p>
                ) : (
                  <div className="nested-manager-list" style={{ maxHeight: '350px', overflowY: 'auto' }}>
                    {selectedLessonForQuizzes.quizzes.map((quiz, index) => (
                      <div key={quiz.id} className="nested-item-row">
                        <div className="nested-item-info">
                          <div className="nested-item-order">{index + 1}</div>
                          <div>
                            <div className="nested-item-title">{quiz.question}</div>
                            <div className="nested-item-subtitle" style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap', marginTop: '0.35rem' }}>
                              {quiz.options.map((option, oIdx) => (
                                <span 
                                  key={oIdx} 
                                  style={{ 
                                    padding: '0.15rem 0.5rem',
                                    borderRadius: '4px',
                                    fontSize: '0.75rem',
                                    background: oIdx === quiz.correctIndex ? 'rgba(0, 230, 118, 0.12)' : 'rgba(255,255,255,0.03)',
                                    border: oIdx === quiz.correctIndex ? '1px solid rgba(0, 230, 118, 0.3)' : '1px solid var(--glass-border)',
                                    color: oIdx === quiz.correctIndex ? 'var(--success)' : 'var(--text-secondary)'
                                  }}
                                >
                                  {option}
                                </span>
                              ))}
                            </div>
                          </div>
                        </div>
                        <div className="nested-item-actions">
                          <button className="btn-icon-glass" onClick={() => openLessonQuizForm(quiz)} title="Edit Question">
                            <Edit3 size={14} />
                          </button>
                          <button className="btn-icon-glass danger" onClick={() => handleDeleteLessonQuiz(quiz.id)} title="Delete Question">
                            <Trash2 size={14} />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                <div className="modal-footer" style={{ padding: '1rem 0 0 0', borderTop: '1px solid var(--glass-border)', marginTop: '0.5rem' }}>
                  <button type="button" className="btn-secondary-glass" onClick={() => setIsLessonQuizModalOpen(false)} style={{ width: '100%' }}>
                    Done
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

    </div>
  );
}

export default App;
