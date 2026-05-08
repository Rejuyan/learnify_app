import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LessonTile extends StatelessWidget {
  final String title;
  final int durationMinutes;
  final int index;
  final bool isCompleted;
  final bool isCurrent;
  final Color accentColor;
  final VoidCallback onTap;

  const LessonTile({
    super.key,
    required this.title,
    required this.durationMinutes,
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent
                  ? accentColor.withValues(alpha: 0.08)
                  : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? accentColor.withValues(alpha: 0.25)
                    : AppTheme.divider,
                width: 1,
              ),
              boxShadow: isCurrent ? AppTheme.cardShadowLight : null,
            ),
            child: Row(
              children: [
                // Lesson number / check
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppTheme.successGreen,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title & duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$durationMinutes min',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: isCurrent ? accentColor : AppTheme.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
