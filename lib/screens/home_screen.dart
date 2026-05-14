import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sample_data.dart';
import '../models/course.dart';
import '../services/progress_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/theme_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/course_card.dart';
import '../widgets/progress_indicator_widget.dart';
import 'course_detail_screen.dart';
import 'progress_screen.dart';
import 'my_learning_screen.dart';
import 'trophy_room_screen.dart';
import 'auth/login_screen.dart';
import 'auth/edit_profile_screen.dart';

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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
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
    final firestoreService = FirestoreService();

    // Ensure we have the latest user data
    if (AuthService().currentUser != null) {
      await AuthService().currentUser!.reload();
    }

    final Map<String, double> progress = {};
    Course? continueCourse;
    double maxIncompleteProgress = -1;
    double totalProgressOfEnrolled = 0;
    int enrolledCount = 0;

    final isCloud = firestoreService.isLoggedIn;

    // Get enrolled course IDs first
    final enrolledIds = isCloud
        ? await firestoreService.getEnrolledCourseIds()
        : <String>[];

    for (final course in sampleCourses) {
      final p = isCloud
          ? await firestoreService.getCourseProgress(course.id, course.totalLessons)
          : await ProgressService.getCourseProgress(course.id, course.totalLessons);
      progress[course.id] = p;

      // Only count towards overall if enrolled or has progress
      final isEnrolled = enrolledIds.contains(course.id) || p > 0;
      if (isEnrolled) {
        totalProgressOfEnrolled += p;
        enrolledCount++;
      }

      // Find highest progress course that is not 100% complete
      if (p > 0 && p < 1.0) {
        if (p > maxIncompleteProgress) {
          maxIncompleteProgress = p;
          continueCourse = course;
        }
      }
    }

    final overallProgress = enrolledCount > 0
        ? totalProgressOfEnrolled / enrolledCount
        : 0.0;

    final stats = isCloud
        ? await firestoreService.getOverallStats(
            sampleCourses.map((c) => c.id).toList(),
            {for (var c in sampleCourses) c.id: c.totalLessons},
          )
        : await ProgressService.getOverallStats(
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
        if (name.isNotEmpty) {
          name = name[0].toUpperCase() + name.substring(1);
        }
      }
    }

    if (mounted) {
      setState(() {
        _courseProgress = progress;
        _overallProgress = overallProgress;
        _overallStats = stats;
        _continueLearningCourse = continueCourse;
        _userName = name;
      });
    }
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryPurpleLight.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 40, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 16),
              Text(
                user != null ? (user.email ?? 'Logged In') : 'Guest User',
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (user != null && user.emailVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Verified', style: TextStyle(color: AppTheme.successGreen, fontSize: 12)),
                )
              else if (user != null && !user.emailVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Unverified Email', style: TextStyle(color: AppTheme.warningYellow, fontSize: 12)),
                ),
              const SizedBox(height: 32),
              
              // Dark Mode Toggle Row
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeNotifier(),
                builder: (context, mode, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dark_mode_rounded, color: AppTheme.primaryPurple, size: 20),
                    ),
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Switch(
                      value: ThemeNotifier().isDark,
                      activeThumbColor: AppTheme.primaryPurple,
                      onChanged: (_) => ThemeNotifier().toggleTheme(),
                    ),
                  );
                },
              ),

              // Trophy Room Button
              if (user != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TrophyRoomScreen()));
                  },
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD93D), size: 20),
                  ),
                  title: const Text('Trophy Room', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              const SizedBox(height: 8),
              if (user != null) ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    if (result == true) {
                      _loadProgress();
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    await AuthService().signOut();
                    nav.pop();
                    _loadProgress();
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
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const LoginScreen())
                    ).then((_) => _loadProgress());
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Log In / Register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 20) return 'Good Evening';
    return 'Good Night';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentNavIndex == 0
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
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
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            onTap: (i) {
              setState(() => _currentNavIndex = i);
              if (i == 1) _loadProgress();
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_rounded),
                label: 'My Learning',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Progress',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Gradient Header ──────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showProfileMenu,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            hintText: 'Search courses...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Continue Learning Card ─────────────────
          if (_continueLearningCourse != null && _searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: _continueLearningCourse!))
                    );
                    _loadProgress();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.softCard(),
                    child: Row(
                      children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(
                            color: _continueLearningCourse!.color.withValues(alpha: 0.1), 
                            borderRadius: BorderRadius.circular(14)
                          ),
                          child: Icon(_continueLearningCourse!.icon, color: _continueLearningCourse!.color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Continue Learning', 
                                style: TextStyle(color: AppTheme.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _continueLearningCourse!.title, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary), 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryPurple, size: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ─── Gamified Progress Card ─────────────────
          if (_searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.trendingCard(),
                  child: Row(
                    children: [
                      AnimatedCircularProgress(
                        progress: _overallProgress,
                        size: 64,
                        strokeWidth: 5,
                        progressColor: AppTheme.accentOrange,
                        center: Text(
                          '${(_overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Progress',
                                    style: TextStyle(
                                      color: AppTheme.accentOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Keep learning to reach your goals!',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppTheme.accentYellow),
                                const SizedBox(width: 4),
                                Text(
                                  '${_overallStats['totalQuizScore'] ?? 0} Points Earned',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Category Chips ─────────────────────────
          if (_searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildCategoryChip('All'),
                      ...allCategories.map(_buildCategoryChip),
                    ],
                  ),
                ),
              ),
            ),

          // ─── Section title ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Row(
                children: [
                  Text(
                    _searchQuery.isNotEmpty 
                        ? 'Suggested For You' 
                        : (_selectedCategory == 'All' ? 'Top Rated' : _selectedCategory),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  if (_searchQuery.isEmpty)
                    Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Course Grid ──────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            sliver: _filteredCourses.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            const Text('No courses found.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = _filteredCourses[index];
                        return CourseCard(
                          course: course,
                          progress: _courseProgress[course.id] ?? 0.0,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CourseDetailScreen(course: course),
                              ),
                            );
                            _loadProgress();
                          },
                        );
                      },
                      childCount: _filteredCourses.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? null : AppTheme.cardShadowLight,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryPurple
                  : AppTheme.divider,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
