import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'certificate_screen.dart';

class TrophyRoomScreen extends StatefulWidget {
  const TrophyRoomScreen({super.key});

  @override
  State<TrophyRoomScreen> createState() => _TrophyRoomScreenState();
}

class _TrophyRoomScreenState extends State<TrophyRoomScreen> {
  List<Map<String, dynamic>> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    if (!FirestoreService().isLoggedIn) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final certs = await FirestoreService()
          .getEarnedCertificates()
          .timeout(const Duration(seconds: 6), onTimeout: () => []);
      if (mounted) {
        setState(() {
          _certificates = certs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Trophy Room',
            style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: user == null
          ? _buildNotLoggedIn(context)
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context, isDark),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            const Text('Log in to view your certificates',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    if (_certificates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded,
                  size: 80,
                  color: AppTheme.textMuted.withValues(alpha: 0.4)),
              const SizedBox(height: 20),
              const Text(
                'No Certificates Yet',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete a course and pass the final quiz\nto earn your first certificate!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _certificates.length,
      itemBuilder: (context, index) {
        final cert = _certificates[index];
        final earnedAt = cert['earnedAt'] as String? ?? '';
        String formattedDate = '';
        if (earnedAt.isNotEmpty) {
          try {
            final dt = DateTime.parse(earnedAt);
            formattedDate = '${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {}
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CertificateScreen(
                    courseTitle: cert['courseTitle'] ?? '',
                    courseId: cert['courseId'] ?? '',
                    isNewlyEarned: false,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1040), Color(0xFF0D0D2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD93D), Color(0xFFFF8C42)],
                      ),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert['courseTitle'] ?? 'Unknown Course',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        if (formattedDate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Earned on $formattedDate',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFFFD93D)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
