import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final double progress;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.progress,
    required this.onTap,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use soft tints for card backgrounds matching reference styles
    final Color cardBg = isDark
        ? const Color(0xFF1E1C2E)
        : widget.course.color.withValues(alpha: 0.08);

    final Color cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : widget.course.color.withValues(alpha: 0.12);

    // Mock star rating deterministically
    final double rating = 3.5 + (widget.course.title.hashCode % 15) / 10;
    final int progressPercent = (widget.progress * 100).toInt();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.course.color.withValues(alpha: isDark ? 0.01 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              // 1. Left side: Circular Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(
                  widget.course.icon,
                  color: widget.course.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // 2. Middle: Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      children: [
                        Text(
                          widget.course.category.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? AppTheme.primaryPurpleLight : widget.course.color.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB74D), size: 10),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      widget.course.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E1E2E),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Progress Row & Bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: widget.progress,
                              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE4E1FA),
                              valueColor: AlwaysStoppedAnimation<Color>(widget.course.color),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          progressPercent > 0 ? '$progressPercent% complete' : 'Start course',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : const Color(0xFF6E6E82),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${widget.course.totalLessons} lessons',
                          style: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black38,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. Right side: Arrow forward circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : widget.course.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
