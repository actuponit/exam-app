import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
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
  final IQuestionsLocalDatasource _localDatasource;
  final IQuestionsRemoteDatasource _remoteDatasource;
  final ISubjectLocalDatasource _subjectLocalDatasource;
  final IExamLocalDatasource _examLocalDatasource;
  final LocalAuthDataSource _authLocalDatasource;

  QuestionRepositoryImpl({
    required IQuestionsLocalDatasource localDatasource,
    required IQuestionsRemoteDatasource remoteDatasource,
    required ISubjectLocalDatasource subjectLocalDatasource,
    required IExamLocalDatasource examLocalDatasource,
    required LocalAuthDataSource authLocalDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _subjectLocalDatasource = subjectLocalDatasource,
        _examLocalDatasource = examLocalDatasource,
        _authLocalDatasource = authLocalDatasource;

  final Map<String, models.Answer> _answers = {};

  @override
  Future<List<Question>> getQuestions({
    required String subjectId,
    String? chapterId,
    required int year,
    String? region,
  }) async {
    final localQuestions = await _localDatasource.getQuestions();
    final filteredQuestions = localQuestions.where((q) {
      bool isMatch = true;
      if (subjectId.isNotEmpty) {
        isMatch = isMatch && q.subject.name == subjectId;
      }
      if (chapterId != null && chapterId.isNotEmpty) {
        isMatch = isMatch && q.chapter.id == chapterId;
      }
      if (year > 0) {
        isMatch = isMatch && q.year == year;
      }
      if (region != null && region.isNotEmpty) {
        isMatch = isMatch && q.region == region;
      }
      return isMatch;
    }).toList();
    return filteredQuestions;
  }

  @override
  Future<void> saveAnswer(models.Answer answer) async {
    final q = await _localDatasource.getQuestion(answer.question.id);
    if (q?.isAttempted == false) {
      final subjects = await _subjectLocalDatasource.getSubjects();
      final subject =
          subjects.firstWhere((s) => s.name == answer.question.subject.name);
      await _subjectLocalDatasource.updateSubject(subject.copyWith(
        attempted: subject.attempted + 1,
      ));
      await _localDatasource
          .updateQuestion(answer.question.copyWith(isAttempted: true));
    }
  }

  @override
  Future<List<models.Answer>> getSavedAnswers(List<String> questionIds) async {
    return questionIds
        .where((id) => _answers.containsKey(id))
        .map((id) => _answers[id]!)
        .toList();
  }

  @override
  Future<void> getAllQuestions({bool ensureBackend = false}) async {
    try {
      if (ensureBackend) {
        await _localDatasource.clearQuestions();
      }
      // First check if we have data in local storage
      final localQuestions = await _localDatasource.getQuestions();

      // If we have data locally, return it
      if (localQuestions.isNotEmpty) {
        return;
      }

      // If no local data, fetch from remote
      final int? userId = await _authLocalDatasource.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final questionsMap =
          await _remoteDatasource.getQuestions(userId.toString());

      // Convert the map to a flat list of questions
      final List<Question> allQuestions =
          questionsMap.values.expand((questions) => questions).toList();
      await _localDatasource.saveQuestions(allQuestions);
      await saveSubjects(allQuestions, questionsMap);
      if (allQuestions.first.region == null) {
        await createExamsFromQuestions(allQuestions);
      } else {
        await createExamsFromQuestionsByRegion(allQuestions);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSubjects(List<Question> questions,
      Map<String, List<Question>> questionsMap) async {
    List<Subject> subjects = [];
    for (final subjectName in questionsMap.keys) {
      subjects.add(Subject(
        id: subjectName,
        name: subjectName,
        total: questionsMap[subjectName]?.length ?? 0,
        iconName: subjectName.toLowerCase(),
        duration: questionsMap[subjectName]?.first.subject.duration,
      ));
    }
    await _subjectLocalDatasource.saveSubjects(subjects);
  }

  Future<void> createExamsFromQuestions(List<Question> questions) async {
    // Group questions by year and subject
    final Map<String, Map<int, List<Question>>> groupedQuestions = {};

    for (final question in questions) {
      if (question.year == null) continue;

      final subjectId = question.subject.name;
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
        }).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

        // Create exam
        final exam = Exam(
          id: 'exam_${subjectId}_$year',
          subjectId: subjectId,
          year: year,
          title: '${questions.first.subject.name} Exam',
          totalQuestions: questions.length,
          durationMins: 60,
          chapters: chapters,
        );

        exams.add(exam);
      });
    });
    await _examLocalDatasource.clearExams();
    // Save exams to local storage
    await _examLocalDatasource.saveExams(exams);
  }

  Future<void> createExamsFromQuestionsByRegion(
      List<Question> questions) async {
    // Group questions by year and subject
    final Map<String, Map<int, Map<String, List<Question>>>> groupedQuestions =
        {};

    for (final question in questions) {
      if (question.year == null) continue;

      final subjectId = question.subject.name;
      final year = question.year!;
      final region = question.region;

      if (region == null) continue;

      groupedQuestions.putIfAbsent(subjectId, () => {});
      groupedQuestions[subjectId]!.putIfAbsent(year, () => {});
      groupedQuestions[subjectId]![year]!.putIfAbsent(region, () => []);
      groupedQuestions[subjectId]![year]![region]!.add(question);
    }

    // Create exams for each year-subject combination
    final List<Exam> exams = [];

    groupedQuestions.forEach((subjectId, yearQuestions) {
      yearQuestions.forEach((year, questions) {
        questions.forEach((region, questions) {
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
          }).toList()
            ..sort((a, b) => a.id.compareTo(b.id));

          // Create exam
          final exam = Exam(
            id: 'exam_${subjectId}_$year _ $region',
            subjectId: subjectId,
            year: year,
            title: '${questions.first.subject.name} Exam',
            totalQuestions: questions.length,
            durationMins: 60,
            chapters: chapters,
            region: region,
          );

          exams.add(exam);
        });
      });
    });
    await _examLocalDatasource.clearExams();
    // Save exams to local storage
    await _examLocalDatasource.saveExams(exams);
  }
}
