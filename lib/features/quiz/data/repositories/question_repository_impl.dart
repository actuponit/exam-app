import 'package:exam_app/core/di/modules/quiz_module.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import '../../domain/models/question.dart';
import '../../domain/models/answer.dart' as models;
import '../../domain/repositories/question_repository.dart';
import 'package:exam_app/features/quiz/data/datasource/questions_local_datasource.dart';
import 'package:exam_app/features/quiz/data/datasource/questions_remote_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/exam_local_datasource.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final Map<String, Question> _questions = {
    'q1': Question(
      id: 'q1',
      text: 'What is the SI unit of force?',
      options: const [
        Option(id: '1', text: 'Newton (N)'),
        Option(id: '2', text: 'Joule (J)'),
        Option(id: '3', text: 'Pascal (Pa)'),
        Option(id: '4', text: 'Watt (W)'),
      ],
      correctOption: 'Newton (N)',
      explanation:
          'The SI unit of force is the Newton (N), which is defined as the force needed to accelerate 1 kilogram of mass at the rate of 1 meter per second squared.',
      chapter:
          ExamChapter(id: '1', name: 'Forces and Motion', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: const Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q2': Question(
      id: 'q2',
      text:
          'If F = ma, what is the acceleration when a force of 10N is applied to a mass of 2kg?',
      options: const [
        Option(id: '1', text: '2 m/s²'),
        Option(id: '2', text: '5 m/s²'),
        Option(id: '3', text: '8 m/s²'),
      ],
      correctOption: '2',
      explanation: 'Using \$F = ma\$:\n\$10 = 2a\$\n\$a = 5\$ m/s²',
      chapter:
          ExamChapter(id: '1', name: 'Forces and Motion', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q3': Question(
      id: 'q3',
      text: 'What is the formula for kinetic energy?',
      options: const [
        Option(id: '1', text: '\$KE = \\frac{1}{2}mv^2\$'),
        Option(id: '2', text: '\$KE = mgh\$'),
        Option(id: '3', text: '\$KE = mv\$'),
        Option(id: '4', text: '\$KE = \\frac{1}{2}mv\$'),
      ],
      correctOption: '1',
      explanation:
          'Kinetic energy (KE) is the energy possessed by an object due to its motion. The formula is \$KE = \\frac{1}{2}mv^2\$ where m is mass and v is velocity.',
      chapter: ExamChapter(id: '1', name: 'Energy', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q4': Question(
      id: 'q4',
      text:
          'What is the relationship between wavelength (λ) and frequency (f) of a wave if c is the speed of light?',
      options: const [
        Option(id: '1', text: '\$c = λf\$'),
        Option(id: '2', text: '\$c = \\frac{λ}{f}\$'),
        Option(id: '3', text: '\$c = λ + f\$'),
        Option(id: '4', text: '\$c = \\frac{f}{λ}\$'),
      ],
      correctOption: '1',
      explanation:
          'The wave equation states that wave speed equals wavelength times frequency: \$c = λf\$. This applies to all waves, including light waves.',
      chapter: ExamChapter(id: '1', name: 'Waves', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q5': Question(
      id: 'q5',
      text:
          'What is the equivalent resistance of two resistors R₁ and R₂ connected in parallel?',
      options: const [
        Option(
            id: '1',
            text: '\$\\frac{1}{R_{eq}} = \\frac{1}{R_1} + \\frac{1}{R_2}\$'),
        Option(id: '2', text: '\$R_{eq} = R_1 + R_2\$'),
        Option(id: '3', text: '\$R_{eq} = \\sqrt{R_1R_2}\$'),
        Option(id: '4', text: '\$R_{eq} = \\frac{R_1R_2}{R_1 + R_2}\$'),
      ],
      correctOption: '1',
      explanation:
          'For resistors in parallel, the reciprocal of the equivalent resistance equals the sum of the reciprocals of individual resistances.',
      chapter: ExamChapter(id: '1', name: 'Electricity', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q6': Question(
      id: 'q6',
      text: 'What is the principle of conservation of momentum?',
      options: const [
        Option(
            id: '1',
            text: 'Total momentum remains constant in an isolated system'),
        Option(
            id: '2',
            text: 'Total energy remains constant in an isolated system'),
        Option(
            id: '3',
            text: 'Total force remains constant in an isolated system'),
        Option(
            id: '4', text: 'Total mass remains constant in an isolated system'),
      ],
      correctOption: '1',
      explanation:
          'The principle of conservation of momentum states that in an isolated system (no external forces), the total momentum before and after a collision remains constant.',
      chapter:
          ExamChapter(id: '1', name: 'Forces and Motion', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q7': Question(
      id: 'q7',
      text:
          'What is the relationship between pressure (P), volume (V), and temperature (T) for an ideal gas?',
      options: const [
        Option(id: '1', text: '\$PV = nRT\$'),
        Option(id: '2', text: '\$PV = nR/T\$'),
        Option(id: '3', text: '\$PV = RT/n\$'),
        Option(id: '4', text: '\$PV = nRT/T\$'),
      ],
      correctOption: '1',
      explanation:
          'The ideal gas law states that \$PV = nRT\$, where n is the number of moles and R is the gas constant. This equation describes the relationship between pressure, volume, and temperature of an ideal gas.',
      chapter: ExamChapter(id: '1', name: 'Thermodynamics', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
    'q8': Question(
      id: 'q8',
      text:
          'What is the magnitude of gravitational force between two masses m₁ and m₂ separated by distance r?',
      options: const [
        Option(id: '1', text: '\$F = G\\frac{m_1m_2}{r^2}\$'),
        Option(id: '2', text: '\$F = G\\frac{m_1m_2}{r}\$'),
        Option(id: '3', text: '\$F = G\\frac{m_1+m_2}{r^2}\$'),
        Option(id: '4', text: '\$F = G\\frac{m_1+m_2}{r}\$'),
      ],
      correctOption: '1',
      explanation:
          'Newton\'s law of universal gravitation states that the gravitational force is proportional to the product of masses and inversely proportional to the square of the distance between them.',
      chapter: ExamChapter(id: '1', name: 'Gravitation', questionCount: 10),
      year: 2023,
      createdAt: DateTime(2023),
      subject: Subject(
        id: '1',
        name: 'Physics',
        iconName: 'calculate',
        progress: 0.0,
      ),
    ),
  };
  final IQuestionsLocalDatasource _localDatasource;
  final IQuestionsRemoteDatasource _remoteDatasource;
  final ISubjectLocalDatasource _subjectLocalDatasource;
  final IExamLocalDatasource _examLocalDatasource;

  QuestionRepositoryImpl({
    required IQuestionsLocalDatasource localDatasource,
    required IQuestionsRemoteDatasource remoteDatasource,
    required ISubjectLocalDatasource subjectLocalDatasource,
    required IExamLocalDatasource examLocalDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _subjectLocalDatasource = subjectLocalDatasource,
        _examLocalDatasource = examLocalDatasource;

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
        return q.chapter.id == chapterId;
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
    _answers[answer.questionId] = answer;
  }

  @override
  Future<List<models.Answer>> getSavedAnswers(List<String> questionIds) async {
    return questionIds
        .where((id) => _answers.containsKey(id))
        .map((id) => _answers[id]!)
        .toList();
  }

  @override
  Future<void> getAllQuestions() async {
    try {
      // First check if we have data in local storage
      final localQuestions = await _localDatasource.getQuestions();

      // If we have data locally, return it
      if (localQuestions.isNotEmpty) {
        return;
      }

      // If no local data, fetch from remote
      final questionsMap = await _remoteDatasource.getQuestions("subjectId");
      // Convert the map to a flat list of questions
      final List<Question> allQuestions =
          questionsMap.values.expand((questions) => questions).toList();
      await _localDatasource.saveQuestions(allQuestions);
      await saveSubjects(allQuestions);
      await createExamsFromQuestions(allQuestions);
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<void> saveSubjects(List<Question> questions) async {
    final subjects = questions.map((q) => q.subject).toSet().toList();
    await _subjectLocalDatasource.saveSubjects(subjects);
  }

  Future<void> createExamsFromQuestions(List<Question> questions) async {
    // Group questions by year and subject
    final Map<String, Map<int, List<Question>>> groupedQuestions = {};

    for (final question in questions) {
      if (question.year == null) continue;

      final subjectId = question.subject.id;
      final year = question.year!;

      groupedQuestions.putIfAbsent(subjectId, () => {});
      groupedQuestions[subjectId]!.putIfAbsent(year, () => []);
      groupedQuestions[subjectId]![year]!.add(question);
    }

    // Create exams for each year-subject combination
    final List<Exam> exams = [];

    groupedQuestions.forEach((subjectId, yearQuestions) {
      yearQuestions.forEach((year, questions) {
        // Group questions by chapter
        final Map<String, List<Question>> chapterQuestions = {};
        for (final question in questions) {
          final chapterId = question.chapter.id;
          chapterQuestions.putIfAbsent(chapterId, () => []);
          chapterQuestions[chapterId]!.add(question);
        }

        // Create exam chapters
        final chapters = chapterQuestions.entries.map((entry) {
          return ExamChapter(
            id: entry.key,
            name: entry.value.first.chapter.name,
            questionCount: entry.value.length,
          );
        }).toList();

        // Create exam
        final exam = Exam(
          id: 'exam_${subjectId}_$year',
          subjectId: subjectId,
          year: year,
          title: '$year ${questions.first.subject.name} Exam',
          totalQuestions: questions.length,
          durationMins: 60, // Default duration
          chapters: chapters,
        );

        exams.add(exam);
      });
    });

    // Save exams to local storage
    await _examLocalDatasource.saveExams(exams);
  }
}
