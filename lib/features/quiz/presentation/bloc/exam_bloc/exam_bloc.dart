import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'exam_event.dart';
part 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository examRepository;
  List<Exam> _allExams = [];

  ExamBloc(this.examRepository) : super(ExamInitial()) {
    on<LoadExams>(_onLoadExams);
    on<FilterExamsByChapter>(_onFilterByChapter);
  }

  void _onLoadExams(LoadExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      _allExams = await examRepository.fetchExamsBySubject(event.subjectId);

      final chapters = _extractChapters(_allExams);

      emit(
          ExamLoaded(examsByYear: _groupByYear(_allExams), chapters: chapters));
    } catch (e) {
      emit(const ExamError('Failed to load exams'));
    }
  }

  void _onFilterByChapter(FilterExamsByChapter event, Emitter<ExamState> emit) {
    if (event.chapterId == "all") {
      return _onClearFilter(event, emit);
    }

    final filtered = _allExams
        .where((exam) => exam.containsChapter(event.chapterId))
        .toList();

    final chapters = _extractChapters(_allExams);

    emit(ExamLoaded(
      examsByYear: _groupByYear(filtered),
      filteredChapterId: event.chapterId,
      chapters: chapters,
    ));
  }

  void _onClearFilter(FilterExamsByChapter event, Emitter<ExamState> emit) {
    final chapters = _extractChapters(_allExams);
    emit(ExamLoaded(
      examsByYear: _groupByYear(_allExams),
      chapters: chapters,
    ));
  }

  Map<int, Exam> _groupByYear(List<Exam> exams) {
    final Map<int, Exam> grouped = {};
    for (var exam in exams) {
      grouped.putIfAbsent(exam.year, () => exam);
    }
    return grouped;
  }

  List<ExamChapter> _extractChapters(List<Exam> exams) {
    return exams
        .expand((exam) => exam.chapters)
        .fold<Map<String, ExamChapter>>({}, (map, chapter) {
          map[chapter.id] = chapter;
          return map;
        })
        .values
        .toList();
  }
}
