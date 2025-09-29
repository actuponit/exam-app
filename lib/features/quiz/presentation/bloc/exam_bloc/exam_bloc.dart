import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/quiz/utils/sort_with_chapter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'exam_event.dart';
part 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository examRepository;
  List<Exam> _allExams = [];
  List<ExamChapter> _allChapters = [];
  Map<String, ExamChapter> _allChaptersMap = {};

  ExamBloc(this.examRepository) : super(ExamInitial()) {
    on<LoadExams>(_onLoadExams);
    on<FilterExamsByChapter>(_onFilterByChapter);
  }

  void _onLoadExams(LoadExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      _allExams = await examRepository.fetchExamsBySubject(
        event.subjectId,
        region: event.region,
      );

      _allChapters = _extractChapters(_allExams);

      emit(ExamLoaded(exams: _allExams, chapters: _allChapters));
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

    emit(ExamLoaded(
      exams: filtered,
      filteredChapter: _allChaptersMap[event.chapterId],
      chapters: _allChapters,
    ));
  }

  void _onClearFilter(FilterExamsByChapter event, Emitter<ExamState> emit) {
    emit(ExamLoaded(
      exams: _allExams,
      chapters: _allChapters,
    ));
  }

  List<ExamChapter> _extractChapters(List<Exam> exams) {
    _allChaptersMap = exams
        .expand((exam) => exam.chapters)
        .fold<Map<String, ExamChapter>>({}, (map, chapter) {
      map[chapter.id] = chapter;
      return map;
    });
    return _allChaptersMap.values.toList()
      ..sort((a, b) => sortChapters(a.name, b.name));
  }
}
