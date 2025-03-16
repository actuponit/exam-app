import '../models/question.dart';
import '../models/answer.dart' as models;

class ScoreResult {
  final String grade;
  final double percentage;
  final int correctAnswers;
  final int totalQuestions;
  final Duration? timeSpent;
  final String message;

  const ScoreResult({
    required this.grade,
    required this.percentage,
    required this.correctAnswers,
    required this.totalQuestions,
    this.timeSpent,
    required this.message,
  });
}

class ScoreCalculator {
  static ScoreResult calculateScore(
    List<Question> questions,
    Map<String, models.Answer> answers, {
    DateTime? startTime,
  }) {
    final totalQuestions = questions.length;
    final answeredQuestions = answers.length;
    final correctAnswers = questions.where((q) {
      final answer = answers[q.id];
      return answer != null && answer.selectedOption == q.correctOption;
    }).length;

    final percentage = correctAnswers / totalQuestions;
    final grade = _calculateGrade(percentage);
    final message = _getMotivationalMessage(percentage);
    final timeSpent = startTime != null ? DateTime.now().difference(startTime) : null;

    return ScoreResult(
      grade: grade,
      percentage: percentage,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      timeSpent: timeSpent,
      message: message,
    );
  }

  static String _calculateGrade(double percentage) {
    if (percentage >= 0.9) return 'A+';
    if (percentage >= 0.8) return 'A';
    if (percentage >= 0.7) return 'B';
    if (percentage >= 0.6) return 'C';
    if (percentage >= 0.5) return 'D';
    return 'F';
  }

  static String _getMotivationalMessage(double percentage) {
    if (percentage >= 0.9) {
      return 'Outstanding! You\'ve mastered this topic! 🌟';
    }
    if (percentage >= 0.8) {
      return 'Excellent work! Keep up the great performance! 🎉';
    }
    if (percentage >= 0.7) {
      return 'Good job! You\'re making solid progress! 👍';
    }
    if (percentage >= 0.6) {
      return 'Not bad! A little more practice will help you improve! 💪';
    }
    if (percentage >= 0.5) {
      return 'You\'re getting there! Keep practicing and you\'ll see better results! 📚';
    }
    return 'Don\'t give up! Every attempt is a step toward mastery! 🎯';
  }
}