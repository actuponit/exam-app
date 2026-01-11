import 'package:dio/dio.dart';
import 'package:exam_app/core/error/exceptions.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:exam_app/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:exam_app/features/notes/data/models/note_model.dart';
import '../../domain/models/question.dart';
import '../../domain/models/answer.dart' as models;
import '../../domain/models/download_progress.dart';
import '../../domain/repositories/question_repository.dart';
import '../../domain/services/image_download_service.dart';
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
  final NotesLocalDataSource _notesLocalDatasource;
  final NotesRemoteDataSource _notesRemoteDataSource;
  final ImageDownloadService _imageDownloadService;

  QuestionRepositoryImpl({
    required IQuestionsLocalDatasource localDatasource,
    required IQuestionsRemoteDatasource remoteDatasource,
    required ISubjectLocalDatasource subjectLocalDatasource,
    required IExamLocalDatasource examLocalDatasource,
    required LocalAuthDataSource authLocalDatasource,
    required NotesLocalDataSource notesLocalDatasource,
    required NotesRemoteDataSource notesRemoteDataSource,
    required ImageDownloadService imageDownloadService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _subjectLocalDatasource = subjectLocalDatasource,
        _examLocalDatasource = examLocalDatasource,
        _authLocalDatasource = authLocalDatasource,
        _notesLocalDatasource = notesLocalDatasource,
        _notesRemoteDataSource = notesRemoteDataSource,
        _imageDownloadService = imageDownloadService;

  final Map<String, models.Answer> _answers = {};

  int _total = 0;
  int _count = 0;
  int _totalNote = 0;
  int _countNote = 0;

  @override
  Future<List<Question>> getQuestions({
    required String subjectId,
    String? chapterId,
    required String year,
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

      isMatch = isMatch && q.year == year;

      if (region != null && region.isNotEmpty) {
        isMatch = isMatch && q.region == region;
      }
      return isMatch;
    }).toList();

    return filteredQuestions
      ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
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
  Future<void> getAllQuestions({
    bool ensureBackend = false,
    void Function(DownloadProgress)? onProgress,
  }) async {
    try {
      // Reset progress counters to avoid stale values from previous calls
      _total = 16958887;
      _count = 0;
      _totalNote = 1831788;
      _countNote = 0;

      if (ensureBackend) {
        await _localDatasource.clearQuestions();
      }

      // First check if we have data in local storage
      final localQuestions = await _localDatasource.getQuestions();

      // If we have data locally, return it
      if (localQuestions.isNotEmpty) {
        onProgress?.call(const DownloadProgress(
          phase: SyncPhase.completed,
          message: 'Content loaded from cache',
        ));
        return;
      }

      // Phase 1: Fetch from API
      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.fetchingQuestions,
        apiTasksTotal: 2,
        apiTasksCompleted: 0,
        message: 'Fetching questions and notes...',
      ));

      // If no local data, fetch from remote
      final int? userId = await _authLocalDatasource.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final [questionsMapDynamic, notesDynamic] = await Future.wait([
        _remoteDatasource.getQuestions(userId.toString(), (count, total) {
          _total = total > 0 ? total : _total;
          _count = count;
          _notifyFetchingProgress(onProgress);
        }),
        _notesRemoteDataSource.getNotesByGrade(userId, (count, total) {
          _totalNote = total > 0 ? total : _totalNote;
          _countNote = count;
          _notifyFetchingProgress(onProgress);
        }),
      ]);

      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.fetchingQuestions,
        apiTasksTotal: 2,
        apiTasksCompleted: 2,
        message: 'Questions and notes fetched',
      ));

      final questionsMap = questionsMapDynamic as Map<String, List<Question>>;
      final notes = notesDynamic as List<NoteSubjectModel>;

      // Convert the map to a flat list of questions
      final List<Question> allQuestions =
          questionsMap.values.expand((questions) => questions).toList();

      // Phase 2: Save data (NO IMAGE DOWNLOADS HERE - That's the key!)
      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.savingData,
        dataSaveTasksTotal: 4,
        dataSaveTasksCompleted: 0,
        message: 'Saving content...',
      ));

      await _notesLocalDatasource.saveNotes(notes);
      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.savingData,
        dataSaveTasksTotal: 4,
        dataSaveTasksCompleted: 1,
      ));

      await _localDatasource.saveQuestions(allQuestions);
      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.savingData,
        dataSaveTasksTotal: 4,
        dataSaveTasksCompleted: 2,
      ));

      await saveSubjects(allQuestions, questionsMap);
      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.savingData,
        dataSaveTasksTotal: 4,
        dataSaveTasksCompleted: 3,
      ));

      if (allQuestions.isNotEmpty && allQuestions.first.region == null) {
        await createExamsFromQuestions(allQuestions);
      } else {
        await createExamsFromQuestionsByRegion(allQuestions);
      }

      onProgress?.call(const DownloadProgress(
        phase: SyncPhase.savingData,
        dataSaveTasksTotal: 4,
        dataSaveTasksCompleted: 4,
        message: 'Data saved successfully',
      ));

      // Phase 3: Start background downloads (NON-BLOCKING - Fire and forget!)
      final imageUrls = _extractImageUrls(allQuestions);

      // Fire and forget - downloads happen in background
      _imageDownloadService
          .downloadImagesInBackground(imageUrls)
          .listen((progress) {
        onProgress?.call(progress);
      });

      // Return immediately - app is ready!
      onProgress?.call(DownloadProgress(
        phase: SyncPhase.downloadingImages,
        message: 'App ready! Images downloading in background...',
        imagesTotalCount: imageUrls.length,
        imagesDownloaded: 0,
      ));
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final message = e.response?.data["message"];
        throw ServerException(
            message ?? "An unexpected error ocured during fetching questions");
      }
      throw ServerException("Server Error: ${e.message}");
    } catch (e) {
      throw ServerException(
          "An unexpected error ocured during fetching questions");
    }
  }

  void _notifyFetchingProgress(void Function(DownloadProgress)? onProgress) {
    final total = _total + _totalNote;
    final count = _count + _countNote;
    // Clamp progress to [0.0, 1.0] for safety
    final progress = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

    onProgress?.call(DownloadProgress(
      phase: SyncPhase.fetchingQuestions,
      apiTasksTotal: 2,
      apiTasksCompleted: 0,
      message: progress >= 1.0
          ? 'Decompressing them.'
          : 'Fetching questions and notes...',
      overallProgress: progress,
    ));
  }

  Future<void> saveSubjects(List<Question> questions,
      Map<String, List<Question>> questionsMap) async {
    List<Subject> subjects = [];
    for (final subjectName in questionsMap.keys) {
      subjects.add(
        Subject(
          id: subjectName,
          name: subjectName,
          total: questionsMap[subjectName]?.length ?? 0,
          iconName: subjectName.toLowerCase(),
          duration: questionsMap[subjectName]?.first.subject.duration,
          isSample: questionsMap[subjectName]?.first.subject.isSample ?? false,
        ),
      );
    }
    await _subjectLocalDatasource.saveSubjects(subjects);
  }

  Future<void> createExamsFromQuestions(List<Question> questions) async {
    // Group questions by year and subject
    final Map<String, Map<String, List<Question>>> groupedQuestions = {};

    for (final question in questions) {
      if (question.year == null) continue;

      final subjectId = question.subject.name;
      final year = question.year!;

      groupedQuestions.putIfAbsent(subjectId, () => {});

      groupedQuestions[subjectId]!.putIfAbsent(year.toString(), () => []);
      groupedQuestions[subjectId]![year.toString()]!.add(question);
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
          ..sort((a, b) => a.name
              .trim()
              .toLowerCase()
              .compareTo(b.name.trim().toLowerCase()));

        // Create exam
        final exam = Exam(
          id: 'exam_${subjectId}_$year',
          subjectId: subjectId,
          year: year.toString(),
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
    final Map<String, Map<String, Map<String, List<Question>>>>
        groupedQuestions = {};

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
          }).toList();

          // Create exam
          final exam = Exam(
            id: 'exam_${subjectId}_$year _ $region',
            subjectId: subjectId,
            year: year.toString(),
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

  /// Extract image URLs from questions (replaces old blocking downloadImages method)
  Map<String, String> _extractImageUrls(List<Question> questions) {
    final images = <String, String>{};
    for (final question in questions) {
      if (question.imagePath != null) {
        images[question.questionKey!] = question.imagePath!;
      }
      if (question.explanationImagePath != null) {
        images[question.explanationKey!] = question.explanationImagePath!;
      }

      for (final option in question.options) {
        if (option.imageKey != null) {
          images[option.imageKey!] = option.image!;
        }
      }
    }
    // await _remoteDatasource.downloadImages(images);
    return images;
  }
}
