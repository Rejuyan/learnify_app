import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CertificateScreen extends StatefulWidget {
  final String courseTitle;
  final String courseId;
  final bool isNewlyEarned;

  const CertificateScreen({
    super.key,
    required this.courseTitle,
    required this.courseId,
    this.isNewlyEarned = false,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _particleAnim;

  String _userName = '';
  String _earnedDate = '';

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _earnedDate =
        '${_monthName(now.month)} ${now.day}, ${now.year}';

    final user = AuthService().currentUser;
    if (user != null) {
      _userName = user.displayName?.isNotEmpty == true
          ? user.displayName!
          : (user.email?.split('@')[0] ?? 'Learner');
      if (_userName.isNotEmpty) {
        _userName = _userName[0].toUpperCase() + _userName.substring(1);
      }
    }

    _entryController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _shimmerController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _particleController = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);

    _scaleAnim = CurvedAnimation(
        parent: _entryController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(
        parent: _entryController, curve: const Interval(0.0, 0.6));
    _shimmerAnim = _shimmerController;
    _particleAnim = _particleController;

    _entryController.forward();
    _shimmerController.repeat();
    _particleController.repeat();

    if (widget.isNewlyEarned) {
      FirestoreService().awardCertificate(widget.courseId, widget.courseTitle);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Certificate of Completion',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_particleController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Particle field background
              ...List.generate(20, (i) {
                final angle = (i / 20) * 2 * math.pi +
                    _particleAnim.value * 2 * math.pi;
                final radius = 160 + (i % 5) * 40.0;
                final cx = MediaQuery.of(context).size.width / 2 +
                    math.cos(angle) * radius;
                final cy = MediaQuery.of(context).size.height / 2 +
                    math.sin(angle) * radius;
                final opacity = 0.1 + (math.sin(angle + i) * 0.5 + 0.5) * 0.2;
                return Positioned(
                  left: cx - 3,
                  top: cy - 3,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i % 3 == 0
                            ? AppTheme.primaryPurple
                            : i % 3 == 1
                                ? AppTheme.accentOrange
                                : AppTheme.accentYellow,
                      ),
                    ),
                  ),
                );
              }),
              child!,
            ],
          );
        },
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _CertificatePainter(_shimmerAnim.value),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top emblem
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD93D), Color(0xFFFF8C42)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentOrange
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.emoji_events_rounded,
                                color: Colors.white, size: 44),
                          ),
                          const SizedBox(height: 20),

                          // Header
                          const Text(
                            'CERTIFICATE',
                            style: TextStyle(
                              color: Color(0xFFFFD93D),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                            ),
                          ),
                          const Text(
                            'of Completion',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider line
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: Colors.white.withValues(alpha: 0.15))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD93D), size: 16),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: Colors.white.withValues(alpha: 0.15))),
                            ],
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'This is to certify that',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14),
                          ),
                          const SizedBox(height: 10),

                          // Name
                          Text(
                            _userName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'has successfully completed',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 14),
                          ),
                          const SizedBox(height: 16),

                          // Course title
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryPurple
                                      .withValues(alpha: 0.3),
                                  AppTheme.primaryPurpleDark
                                      .withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.primaryPurpleLight
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              widget.courseTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFD4CDFF),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Date
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: Colors.white.withValues(alpha: 0.15))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(Icons.star_rounded,
                                    color: Color(0xFFFFD93D), size: 16),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: Colors.white.withValues(alpha: 0.15))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: Colors.white38, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _earnedDate,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Learnify Academy',
                            style: TextStyle(
                              color: Color(0xFFFFD93D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificatePainter extends CustomPainter {
  final double shimmerValue;
  _CertificatePainter(this.shimmerValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1040),
          Color(0xFF0D0D2B),
          Color(0xFF1A1040),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // Corner ornamental accents
    _drawCornerOrnament(canvas, size, const Offset(0, 0), false, false);
    _drawCornerOrnament(canvas, size, Offset(size.width, 0), true, false);
    _drawCornerOrnament(canvas, size, Offset(0, size.height), false, true);
    _drawCornerOrnament(
        canvas, size, Offset(size.width, size.height), true, true);

    // Shimmer overlay
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 + shimmerValue * 3, -0.5),
        end: Alignment(-0.5 + shimmerValue * 3, 0.5),
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, shimmerPaint);

    // Gold border
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFD93D),
          Color(0xFFFF8C42),
          Color(0xFFFFD93D),
          Color(0xFF9D8FEF),
          Color(0xFFFFD93D),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);

    // Inner subtle border
    final innerBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(8), const Radius.circular(18)),
      innerBorderPaint,
    );
  }

  void _drawCornerOrnament(
      Canvas canvas, Size size, Offset corner, bool flipX, bool flipY) {
    final paint = Paint()
      ..color = const Color(0xFFFFD93D).withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dx = flipX ? -1.0 : 1.0;
    final dy = flipY ? -1.0 : 1.0;

    canvas.drawLine(corner + Offset(dx * 12, 0), corner + Offset(dx * 28, 0), paint);
    canvas.drawLine(corner + Offset(0, dy * 12), corner + Offset(0, dy * 28), paint);
    canvas.drawCircle(corner + Offset(dx * 10, dy * 10), 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_CertificatePainter old) => old.shimmerValue != shimmerValue;
}
