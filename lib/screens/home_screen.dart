import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/course.dart';
import '../services/local_data_service.dart';
import '../services/auth_service.dart';
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TrophyRoomScreen()));
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

              const SizedBox(height: 8),
              if (user != null) ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    if (result == true) _loadProgress();
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()))
                        .then((_) => _loadProgress());
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Log In / Register'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                ),
              const SizedBox(height: 8),
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ───────────────────────────────────
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_greeting,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14, fontWeight: FontWeight.w500,
                                    )),
                                const SizedBox(height: 4),
                                Text(_userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24, fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _showProfileMenu,
                            child: Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Progress card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            AnimatedCircularProgress(
                              progress: overallProgress,
                              size: 70,
                              strokeWidth: 6,
                              progressColor: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              center: Text(
                                '${(overallProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Overall Progress',
                                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('$lessonsCompleted of $totalLessons lessons done',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15, fontWeight: FontWeight.w600,
                                      )),
                                  if (_continueLearningCourse != null) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CourseDetailScreen(
                                                course: _continueLearningCourse!),
                                          ),
                                        );
                                        _loadProgress();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.play_circle_rounded,
                                                color: Colors.white, size: 14),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Continue: ${_continueLearningCourse!.title}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12, fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Search ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                          color: isSelected ? AppTheme.primaryPurple : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              fontSize: 13, fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Course grid ──────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
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
                          builder: (_) => CourseDetailScreen(course: course),
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
}
