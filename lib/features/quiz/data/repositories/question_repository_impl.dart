import '../../domain/models/question.dart';
import '../../domain/models/answer.dart' as models;
import '../../domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final Map<String, Question> _questions = {
    'q1': Question(
      id: 'q1',
      text: 'What is the SI unit of force?',
      options: [
        'Newton (N)',
        'Joule (J)',
        'Pascal (Pa)',
        'Watt (W)',
      ],
      correctOption: 'Newton (N)',
      explanation: 'The SI unit of force is the Newton (N), which is defined as the force needed to accelerate 1 kilogram of mass at the rate of 1 meter per second squared.',
      chapter: 'Forces and Motion',
      year: 2023,
      createdAt: DateTime(2023),
    ),
    'q2': Question(
      id: 'q2',
      text: 'If \$F = ma\$, what is the acceleration when a force of 10N is applied to a mass of 2kg?',
      options: [
        '2 m/s²',
        '5 m/s²',
        '8 m/s²',
        '10 m/s²',
      ],
      correctOption: '5 m/s²',
      explanation: 'Using \$F = ma\$:\n\$10 = 2a\$\n\$a = 5\$ m/s²',
      chapter: 'Forces and Motion',
      year: 2023,
      createdAt: DateTime(2023),
    ),
    'q3': Question(
      id: 'q3',
      text: 'What is the formula for kinetic energy?',
      options: [
        '\$KE = \\frac{1}{2}mv^2\$',
        '\$KE = mgh\$',
        '\$KE = mv\$',
        '\$KE = \\frac{1}{2}mv\$',
      ],
      correctOption: '\$KE = \\frac{1}{2}mv^2\$',
      explanation: 'Kinetic energy (KE) is the energy possessed by an object due to its motion. The formula is \$KE = \\frac{1}{2}mv^2\$ where m is mass and v is velocity.',
      chapter: 'Energy',
      year: 2023,
      createdAt: DateTime(2023),
    ),
  };

  final Map<String, models.Answer> _answers = {};

  @override
  Future<List<Question>> getQuestions({
    String? chapter,
    int? year,
    int page = 1,
    int pageSize = 3,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final filteredQuestions = _questions.values.where((q) {
      if (chapter != null && chapter.isNotEmpty) {
        return q.chapter == chapter;
      }
      if (year != null && year > 0) {
        return q.year == year;
      }
      return true;
    }).toList();

    final start = (page - 1) * pageSize;
    final end = start + pageSize;

    return filteredQuestions.skip(start).take(end - start).toList();
  }

  @override
  Future<void> saveAnswer(models.Answer answer) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    _answers[answer.questionId] = answer;
  }

  @override
  Future<List<models.Answer>> getSavedAnswers(List<String> questionIds) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return questionIds
        .where((id) => _answers.containsKey(id))
        .map((id) => _answers[id]!)
        .toList();
  }
} 