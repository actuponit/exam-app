import '../../domain/models/question.dart';
import '../../domain/models/answer.dart' as models;
import '../../domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final Map<String, Question> _questions = {
    'q1': Question(
      id: 'q1',
      text: 'What is the SI unit of force?',
      options: const [
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
      options: const [
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
      options: const [
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
    'q4': Question(
      id: 'q4',
      text: 'What is the relationship between wavelength (λ) and frequency (f) of a wave if c is the speed of light?',
      options: const [
        '\$c = λf\$',
        '\$c = \\frac{λ}{f}\$',
        '\$c = λ + f\$',
        '\$c = \\frac{f}{λ}\$',
      ],
      correctOption: '\$c = λf\$',
      explanation: 'The wave equation states that wave speed equals wavelength times frequency: \$c = λf\$. This applies to all waves, including light waves.',
      chapter: 'Waves',
      year: 2023,
      createdAt: DateTime(2023),
    ),
    'q5': Question(
      id: 'q5',
      text: 'What is the equivalent resistance of two resistors R₁ and R₂ connected in parallel?',
      options: const [
        '\$\\frac{1}{R_{eq}} = \\frac{1}{R_1} + \\frac{1}{R_2}\$',
        '\$R_{eq} = R_1 + R_2\$',
        '\$R_{eq} = \\sqrt{R_1R_2}\$',
        '\$R_{eq} = \\frac{R_1R_2}{R_1 + R_2}\$',
      ],
      correctOption: '\$\\frac{1}{R_{eq}} = \\frac{1}{R_1} + \\frac{1}{R_2}\$',
      explanation: 'For resistors in parallel, the reciprocal of the equivalent resistance equals the sum of the reciprocals of individual resistances.',
      chapter: 'Electricity',
      year: 2023,
      createdAt: DateTime(2023),
    ),
    'q6': Question(
      id: 'q6',
      text: 'What is the principle of conservation of momentum?',
      options: const [
        'Total momentum remains constant in an isolated system',
        'Total energy remains constant in an isolated system',
        'Total force remains constant in an isolated system',
        'Total mass remains constant in an isolated system',
      ],
      correctOption: 'Total momentum remains constant in an isolated system',
      explanation: 'The principle of conservation of momentum states that in an isolated system (no external forces), the total momentum before and after a collision remains constant.',
      chapter: 'Forces and Motion',
      year: 2023,
      createdAt: DateTime(2023),
    ),
    'q7': Question(
      id: 'q7',
      text: 'What is the relationship between pressure (P), volume (V), and temperature (T) for an ideal gas?',
      options: const [
        '\$PV = nRT\$',
        '\$P = nRT\$',
        '\$V = nRT\$',
        '\$T = nRPV\$',
      ],
      correctOption: '\$PV = nRT\$',
      explanation: 'The ideal gas law states that \$PV = nRT\$, where n is the number of moles and R is the gas constant. This equation describes the relationship between pressure, volume, and temperature of an ideal gas.',
      chapter: 'Thermodynamics',
      year: 2023,
      createdAt: DateTime(2023),
    ),
    'q8': Question(
      id: 'q8',
      text: 'What is the magnitude of gravitational force between two masses m₁ and m₂ separated by distance r?',
      options: const [
        '\$F = G\\frac{m_1m_2}{r^2}\$',
        '\$F = G\\frac{m_1m_2}{r}\$',
        '\$F = G\\frac{m_1+m_2}{r^2}\$',
        '\$F = G\\frac{m_1+m_2}{r}\$',
      ],
      correctOption: '\$F = G\\frac{m_1m_2}{r^2}\$',
      explanation: 'Newton\'s law of universal gravitation states that the gravitational force is proportional to the product of masses and inversely proportional to the square of the distance between them.',
      chapter: 'Gravitation',
      year: 2023,
      createdAt: DateTime(2023),
    ),
  };

  final Map<String, models.Answer> _answers = {};

  @override
  Future<List<Question>> getQuestions({
    required String subjectId,
    String? chapterId,
    required int year,
    int page = 1,
    int pageSize = 3,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final filteredQuestions = _questions.values.where((q) {
      if (chapterId != null && chapterId.isNotEmpty) {
        return q.chapter == chapterId;
      }
      if (year > 0) {
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