import 'package:flutter/material.dart';
import '../../domain/services/score_calculator.dart';

class GradeData {
  final String grade;
  final String range;
  final Color color;
  final Color backgroundColor;
  final String icon;
  final String message;

  const GradeData({
    required this.grade,
    required this.range,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    required this.message,
  });
}

class ResultDialog extends StatelessWidget {
  final ScoreResult scoreResult;
  final VoidCallback onClose;

  const ResultDialog({
    super.key,
    required this.scoreResult,
    required this.onClose,
  });

  static const List<GradeData> _gradeData = [
    GradeData(
      grade: "A+",
      range: "90–100",
      color: Color(0xFF6A0DAD),
      backgroundColor: Color(0xFFEFE6FA),
      icon: "🌟",
      message:
          "Outstanding! You've mastered Ethio Exam Hub materials. Keep shining!",
    ),
    GradeData(
      grade: "A",
      range: "85–89",
      color: Color(0xFF28A745),
      backgroundColor: Color(0xFFE6F4EA),
      icon: "✅",
      message:
          "Excellent! Ethio Exam Hub is working for you — A+ is within reach!",
    ),
    GradeData(
      grade: "B+",
      range: "80–84",
      color: Color(0xFF007BFF),
      backgroundColor: Color(0xFFE6F0FC),
      icon: "👍",
      message:
          "Great job! Almost there — keep using Ethio Exam Hub to level up.",
    ),
    GradeData(
      grade: "B",
      range: "70–79",
      color: Color(0xFF3399FF),
      backgroundColor: Color(0xFFEDF5FF),
      icon: "💪",
      message: "Good effort! Stay consistent with Ethio Exam Hub learning.",
    ),
    GradeData(
      grade: "C+",
      range: "60–69",
      color: Color(0xFFFFC107),
      backgroundColor: Color(0xFFFFF8E1),
      icon: "📘",
      message: "Not bad! Review and practice more with Ethio Exam Hub.",
    ),
    GradeData(
      grade: "C",
      range: "50–59",
      color: Color(0xFFFFCD39),
      backgroundColor: Color(0xFFFFF9E5),
      icon: "📚",
      message: "You're getting there! Stick with Ethio Exam Hub.",
    ),
    GradeData(
      grade: "D",
      range: "40–49",
      color: Color(0xFFFD7E14),
      backgroundColor: Color(0xFFFFF2E6),
      icon: "🛠️",
      message: "Keep going! Use Ethio Exam Hub to focus and improve.",
    ),
    GradeData(
      grade: "F",
      range: "0–39",
      color: Color(0xFFDC3545),
      backgroundColor: Color(0xFFFDE9EB),
      icon: "🚨",
      message:
          "Don't give up! Ethio Exam Hub is your tool for a strong comeback.",
    ),
  ];

  GradeData _getGradeData(double percentage) {
    if (percentage >= 90) return _gradeData[0]; // A+
    if (percentage >= 85) return _gradeData[1]; // A
    if (percentage >= 80) return _gradeData[2]; // B+
    if (percentage >= 70) return _gradeData[3]; // B
    if (percentage >= 60) return _gradeData[4]; // C+
    if (percentage >= 50) return _gradeData[5]; // C
    if (percentage >= 40) return _gradeData[6]; // D
    return _gradeData[7]; // F
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final gradeData = _getGradeData(scoreResult.percentage);

    return Dialog(
      backgroundColor: isDarkMode ? colorScheme.surface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? colorScheme.surface : Colors.white,
              isDarkMode
                  ? colorScheme.surface.withOpacity(0.8)
                  : gradeData.backgroundColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Quiz Results',
              style: theme.textTheme.headlineSmall?.copyWith(
                color:
                    isDarkMode ? colorScheme.onSurface : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Grade Icon and Badge
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? gradeData.color.withOpacity(0.2)
                    : gradeData.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gradeData.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Icon
                  Text(
                    gradeData.icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),

                  // Grade
                  Text(
                    gradeData.grade,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: gradeData.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Percentage
                  Text(
                    '${scoreResult.percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color:
                          isDarkMode ? colorScheme.onSurface : gradeData.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Score Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? colorScheme.surfaceVariant.withOpacity(0.3)
                    : colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: gradeData.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Correct: ${scoreResult.correctAnswers}/${scoreResult.totalQuestions}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDarkMode
                          ? colorScheme.onSurface
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Motivational Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? gradeData.color.withOpacity(0.1)
                    : gradeData.backgroundColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gradeData.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                gradeData.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? colorScheme.onSurface : gradeData.color,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onClose,
                style: FilledButton.styleFrom(
                  backgroundColor: gradeData.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue Learning',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
