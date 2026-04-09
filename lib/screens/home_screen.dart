// ignore_for_file: unused_import, unused_field, unused_element

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../data/sample_data.dart';
import '../models/course.dart';
import '../services/local_data_service.dart';
import '../services/auth_service.dart';
import '../services/theme_notifier.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/course_card.dart';
import '../widgets/progress_indicator_widget.dart';
import 'course_detail_screen.dart';
import 'progress_screen.dart';
import 'my_learning_screen.dart';
import 'trophy_room_screen.dart';
import 'auth/login_screen.dart';
import 'auth/edit_profile_screen.dart';
import 'landing_screen.dart';
import '../utils/network_simulator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Map<String, double> _courseProgress = {};
  double _overallProgress = 0.0;
  Map<String, dynamic> _overallStats = {};
  Course? _continueLearningCourse;
  String _userName = 'Guest';
  int _certificatesCount = 0;
  String? _profilePhotoBase64;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _ds = LocalDataService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800), vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _loadProgress();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    await updateCoursesFromFirestore();
    await _ds.syncWithCloud();

    final Map<String, double> progress = {};
    Course? continueCourse;
    double maxIncompleteProgress = -1;
    double totalProgressOfEnrolled = 0;
    int enrolledCount = 0;

    final enrolledIds = await _ds.getEnrolledCourseIds();

    for (final course in sampleCourses) {
      final p = await _ds.getCourseProgress(course.id, course.totalLessons);
      progress[course.id] = p;

      final isEnrolled = enrolledIds.contains(course.id) || p > 0;
      if (isEnrolled) {
        totalProgressOfEnrolled += p;
        enrolledCount++;
      }

      if (p > 0 && p < 1.0) {
        if (p > maxIncompleteProgress) {
          maxIncompleteProgress = p;
          continueCourse = course;
        }
      }
    }

    final overallProgress = enrolledCount > 0 ? totalProgressOfEnrolled / enrolledCount : 0.0;

    final stats = await _ds.getOverallStats(
      sampleCourses.map((c) => c.id).toList(),
      {for (var c in sampleCourses) c.id: c.totalLessons},
    );

    final user = AuthService().currentUser;
    String name = 'Guest';
    if (user != null) {
      final displayName = user.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        name = displayName;
      } else if (user.email != null) {
        name = user.email!.split('@')[0];
        if (name.isNotEmpty) name = name[0].toUpperCase() + name.substring(1);
      }
    }

    final certs = await _ds.getEarnedCertificates();
    final certCount = certs.length;
    final photo = await _ds.getProfilePhoto();

    if (mounted) {
      setState(() {
        _certificatesCount = certCount;
        _profilePhotoBase64 = photo;
        _courseProgress = progress;
        _overallProgress = overallProgress;
        _overallStats = stats;
        _continueLearningCourse = continueCourse;
        _userName = name;
      });
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 20) return 'Good Evening';
    return 'Good Night';
  }

  void _showProfileMenu() {
    final user = AuthService().currentUser;
    final isDark = ThemeNotifier().isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(_userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (user?.email != null)
                  Text(user!.email!,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 20),
                const Divider(color: AppTheme.divider),
                const SizedBox(height: 8),

                // Dark mode toggle
                StatefulBuilder(
                  builder: (context, setSheetState) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dark_mode_rounded,
                            color: AppTheme.primaryPurple, size: 20),
                      ),
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Switch(
                        value: ThemeNotifier().isDark,
                        activeThumbColor: AppTheme.primaryPurple,
                        onChanged: (_) {
                          ThemeNotifier().toggleTheme();
                          setSheetState(() {});
                        },
                      ),
                    );
                  },
                ),

                // Trophy Room
                if (user != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await NetworkSimulator.delay(context);
                      if (mounted) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const TrophyRoomScreen()));
                      }
                    },
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD93D).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Color(0xFFFFD93D), size: 20),
                    ),
                    title: const Text('Trophy Room', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),

                // Developer Database Migration
                if (user != null && user.email == 'admin@learnify.com')
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Migrating courses to Firestore...')),
                      );
                      try {
                        await FirestoreService().uploadSampleCoursesToFirestore();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully migrated all courses to Firestore!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Migration failed: $e')),
                          );
                        }
                      }
                    },
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_upload_rounded,
                          color: Colors.blue, size: 20),
                    ),
                    title: const Text('Dev: Migrate to Firestore', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),

                const SizedBox(height: 8),
                if (user != null) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await NetworkSimulator.delay(context);
                      if (mounted) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                        if (result == true) _loadProgress();
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryPurple,
                      side: const BorderSide(color: AppTheme.primaryPurple),
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await NetworkSimulator.delay(context);
                      await _ds.resetAllProgress();
                      await AuthService().signOut();
                      nav.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LandingScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ] else
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await NetworkSimulator.delay(context);
                      if (mounted) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()))
                            .then((_) => _loadProgress());
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Log In / Register'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsMenu() {
    final isDark = ThemeNotifier().isDark;
    
    // Generate dynamic notifications
    List<Map<String, dynamic>> notifications = [];
    
    // 1. Welcome / General
    notifications.add({
      'icon': Icons.waving_hand_rounded,
      'color': Colors.blue,
      'title': 'Welcome back, $_userName!',
      'subtitle': 'Ready to learn something new today?',
      'time': 'Just now',
      'onTap': () => Navigator.pop(context),
    });

    // 2. Certificates
    if (_certificatesCount > 0) {
      notifications.add({
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFFFFD93D),
        'title': 'Achievement Unlocked!',
        'subtitle': 'You have earned $_certificatesCount certificate(s). Keep up the great work!',
        'time': 'Recent',
        'onTap': (BuildContext sheetCtx) async {
          Navigator.pop(sheetCtx);
          await NetworkSimulator.delay(context);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TrophyRoomScreen()));
          }
        },
      });
    }

    // 3. Reminder for incomplete course
    if (_continueLearningCourse != null) {
      notifications.add({
        'icon': Icons.play_circle_fill_rounded,
        'color': AppTheme.primaryPurple,
        'title': 'Continue Learning',
        'subtitle': 'Don\'t forget to complete "${_continueLearningCourse!.title}". You left off at ${( (_courseProgress[_continueLearningCourse!.id] ?? 0) * 100).toInt()}%!',
        'time': 'Reminder',
        'onTap': (BuildContext sheetCtx) async {
          Navigator.pop(sheetCtx);
          await NetworkSimulator.delay(context);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: _continueLearningCourse!))).then((_) => _loadProgress());
          }
        },
      });
    }

    // 4. Suggestion (find an unenrolled course)
    final enrolledIds = _courseProgress.keys.where((k) => (_courseProgress[k] ?? 0) > 0).toList();
    final unenrolled = sampleCourses.where((c) => !enrolledIds.contains(c.id)).toList();
    if (unenrolled.isNotEmpty) {
      final suggested = unenrolled.first;
      notifications.add({
        'icon': Icons.lightbulb_rounded,
        'color': Colors.orange,
        'title': 'Suggested for you',
        'subtitle': 'Based on your activity, you might like "${suggested.title}".',
        'time': 'Suggestion',
        'onTap': (BuildContext sheetCtx) async {
          Navigator.pop(sheetCtx);
          await NetworkSimulator.delay(context);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: suggested))).then((_) => _loadProgress());
          }
        },
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E2E))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${notifications.length} New',
                        style: const TextStyle(color: AppTheme.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(color: AppTheme.divider, height: 24),
                  itemBuilder: (context, index) {
                    final note = notifications[index];
                    return InkWell(
                      onTap: () {
                        if (note['onTap'] != null) {
                          note['onTap'](sheetContext);
                        } else {
                          Navigator.pop(sheetContext);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: note['color'].withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(note['icon'], color: note['color'], size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note['title'],
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E1E2E)),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(note['time'], style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note['subtitle'],
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Course> get _filteredCourses {
    var list = sampleCourses;
    if (_selectedCategory != 'All') {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AuthService().currentUser?.email == 'admin@learnify.com'
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryPurple,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
              label: const Text('Return to Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeBody(),
          MyLearningScreen(onRefreshParent: _loadProgress),
          ProgressScreen(onRefresh: _loadProgress),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (i) {
            setState(() => _currentNavIndex = i);
            _loadProgress();
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'My Learning'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          ],
        ),
      ),
    );
  }
  Widget _buildHomeBody() {
    final overallProgress = _overallProgress;
    final lessonsCompleted = _overallStats['lessonsCompleted'] as int? ?? 0;
    final totalLessons = _overallStats['totalLessons'] as int? ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ───────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top profile & notification bar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showProfileMenu,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryPurpleLight.withValues(alpha: 0.2),
                            backgroundImage: _profilePhotoBase64 != null
                                ? MemoryImage(base64Decode(_profilePhotoBase64!))
                                : null,
                            child: _profilePhotoBase64 == null
                                ? const Icon(Icons.person, size: 20, color: AppTheme.primaryPurple)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello $_userName',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E1E2E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Mini horizontal progress line
                            SizedBox(
                              width: 100,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: overallProgress,
                                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFE4E1FA),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Notification bell
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE4E1FA),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: isDark ? Colors.white70 : const Color(0xFF1E1E2E),
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: _showNotificationsMenu,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Title
                    Text(
                      'Your Progress\nToday',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E1E2E),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid Row (Learning Pathway Status + Gauge Card)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Panel: Learning Pathway Status
                        Expanded(
                          flex: 11,
                          child: Container(
                            height: 188,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF16162E) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE4E1FA).withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pathway Status',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // "Achieved" tile
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1D2B2E) : const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text('Achieved', style: TextStyle(color: Colors.teal, fontSize: 8, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 2),
                                            Text('$lessonsCompleted', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1E2E), fontSize: 16, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Container(
                                          width: 24, height: 24,
                                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                          child: const Icon(Icons.north_east_rounded, size: 12, color: Colors.teal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // "Final Score" tile
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2E251D) : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text('Quiz Score', style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 2),
                                            Text(
                                              totalLessons > 0 ? '${(overallProgress * 100).toInt()}%' : '0%',
                                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1E2E), fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 24, height: 24,
                                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                          child: const Icon(Icons.north_east_rounded, size: 12, color: Colors.orange),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right Panel: Progress Gauge + Study Lottie
                        Expanded(
                          flex: 10,
                          child: Container(
                            height: 188,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4E1FA),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                // Gauge & Lottie Row
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Custom Paint Speedometer Gauge
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: CustomPaint(
                                          painter: ProgressGaugePainter(
                                            progress: overallProgress,
                                            activeColor: AppTheme.primaryPurple,
                                            backgroundColor: Colors.white.withValues(alpha: 0.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$_certificatesCount',
                                              style: const TextStyle(
                                                color: AppTheme.primaryPurple,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Beautiful interactive Study Lottie floating card
                                      Expanded(
                                        child: SizedBox(
                                          height: 70,
                                          child: Lottie.network(
                                            'https://assets3.lottiefiles.com/packages/lf20_drow7d1i.json',
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, err, stack) => const Icon(
                                              Icons.school_rounded,
                                              size: 32,
                                              color: AppTheme.primaryPurple,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Certificates',
                                  style: TextStyle(
                                    color: AppTheme.primaryPurple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Graduation Milestone',
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Search ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF16162E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE4E1FA),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE4E1FA).withValues(alpha: 0.7),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ─── Category chips ───────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['All', ...{for (var c in sampleCourses) c.category}]
                    .map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF1E1E2E))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? Colors.white24 : const Color(0xFFE4E1FA)),
                            width: 1,
                          ),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                              color: isSelected
                                  ? (isDark ? Colors.black87 : Colors.white)
                                  : (isDark ? Colors.white60 : Colors.black54),
                              fontSize: 12, fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Course list detailed tiles ────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = _filteredCourses[index];
                  return CourseCard(
                    course: course,
                    progress: _courseProgress[course.id] ?? 0.0,
                    onTap: () async {
                      await NetworkSimulator.delay(context);
                      if (mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailScreen(course: course),
                          ),
                        );
                        _loadProgress();
                      }
                    },
                  );
                },
                childCount: _filteredCourses.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// Custom Painter for the gauge progress arc matching reference image
class ProgressGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;

  ProgressGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background arc (from 140 degrees to 400 degrees)
    const startAngle = 2.44346;
    const sweepAngle = 4.53786;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
