import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/local_data_service.dart';
import '../services/auth_service.dart';
import '../services/certificate_pdf_service.dart';
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

  final _ds = LocalDataService();

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    final certs = await _ds.getEarnedCertificates();
    if (mounted) {
      setState(() {
        _certificates = certs;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _downloadCertificate(Map<String, dynamic> cert) async {
    final user = AuthService().currentUser;
    String userName = 'Learner';
    if (user != null) {
      final displayName = user.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        userName = displayName;
      } else if (user.email != null) {
        final name = user.email!.split('@')[0];
        if (name.isNotEmpty) userName = name[0].toUpperCase() + name.substring(1);
      }
    }

    // Get quiz score for efficiency — default to 100% if not found
    final quiz = await _ds.getQuizScore(cert['courseId'] ?? '');

    if (!mounted) return;
    try {
      // ignore: use_build_context_synchronously
      final savedPath = await CertificatePdfService.saveToDevice(
        studentName: userName,
        courseTitle: cert['courseTitle'] ?? 'Unknown Course',
        score: quiz?['score'] ?? 1,
        totalQuestions: quiz?['total'] ?? 1,
        earnedDate: _formatDate(cert['earnedAt']),
        context: context,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Certificate saved!\n$savedPath',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save PDF: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trophy Room',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading && _certificates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_certificates.length} earned',
                    style: const TextStyle(
                      color: Color(0xFFFFD93D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
          : _buildBody(context, isDark),
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
              SizedBox(
                width: 180,
                height: 180,
                child: Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_touohxv0.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.emoji_events_rounded,
                        size: 80, color: AppTheme.textMuted.withValues(alpha: 0.4));
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No Certificates Yet',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
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
        final dateStr = _formatDate(cert['earnedAt'] as String?);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1040), Color(0xFF0D0D2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                  blurRadius: 12, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Trophy icon
                    Container(
                      width: 56, height: 56,
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
                              fontSize: 16, fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (dateStr.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Earned on $dateStr',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // View certificate button
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded,
                          color: Color(0xFFFFD93D), size: 20),
                      onPressed: () {
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
                      tooltip: 'View Certificate',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 14),

                // Download PDF button
                SizedBox(
                  width: double.infinity,
                  child: _DownloadButton(
                    onTap: () => _downloadCertificate(cert),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Download Button Widget ──────────────────────────────────────────────────
class _DownloadButton extends StatefulWidget {
  final Future<void> Function() onTap;
  const _DownloadButton({required this.onTap});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              try {
                await widget.onTap();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not generate PDF: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
      icon: _loading
          ? const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF1A1040)))
          : const Icon(Icons.save_alt_rounded, size: 18),
      label: Text(_loading ? 'Saving...' : 'Save Certificate to Device'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD93D),
        foregroundColor: const Color(0xFF1A1040),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
