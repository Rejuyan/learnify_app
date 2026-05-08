import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizOption extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;
  final VoidCallback? onTap;

  const QuizOption({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    this.isCorrect,
    required this.showResult,
    this.onTap,
  });

  Color get _backgroundColor {
    if (!showResult) {
      return isSelected
          ? AppTheme.primaryPurple.withValues(alpha: 0.08)
          : AppTheme.surfaceCard;
    }
    if (isCorrect == true) {
      return AppTheme.successGreen.withValues(alpha: 0.08);
    }
    if (isSelected && isCorrect == false) {
      return AppTheme.errorRed.withValues(alpha: 0.08);
    }
    return AppTheme.surfaceCard;
  }

  Color get _borderColor {
    if (!showResult) {
      return isSelected
          ? AppTheme.primaryPurple.withValues(alpha: 0.4)
          : AppTheme.divider;
    }
    if (isCorrect == true) {
      return AppTheme.successGreen.withValues(alpha: 0.5);
    }
    if (isSelected && isCorrect == false) {
      return AppTheme.errorRed.withValues(alpha: 0.5);
    }
    return AppTheme.divider;
  }

  IconData? get _trailingIcon {
    if (!showResult) return null;
    if (isCorrect == true) return Icons.check_circle_rounded;
    if (isSelected && isCorrect == false) return Icons.cancel_rounded;
    return null;
  }

  Color get _trailingIconColor {
    if (isCorrect == true) return AppTheme.successGreen;
    return AppTheme.errorRed;
  }

  String get _label {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    return index < labels.length ? labels[index] : '${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 1.5),
              boxShadow: isSelected && !showResult
                  ? AppTheme.cardShadowLight
                  : null,
            ),
            child: Row(
              children: [
                // Label circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected && !showResult
                        ? AppTheme.primaryPurple.withValues(alpha: 0.12)
                        : AppTheme.chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _label,
                      style: TextStyle(
                        color: isSelected && !showResult
                            ? AppTheme.primaryPurple
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_trailingIcon != null)
                  Icon(_trailingIcon, color: _trailingIconColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
