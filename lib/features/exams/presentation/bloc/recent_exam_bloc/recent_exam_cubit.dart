import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/exams/presentation/bloc/recent_exam_bloc/recent_exam_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentExamCubit extends Cubit<RecentExamState> {
  final ExamRepository examRepo;

  RecentExamCubit(this.examRepo) : super(RecentExamInitial());

  Future<void> loadRecentExam() async {
    try {
      emit(RecentExamLoading());
      final recentExam = await examRepo.getRecentExam();
      emit(RecentExamLoaded(recentExam: recentExam));
    } catch (e) {
      emit(RecentExamError(e.toString()));
    }
  }

  Future<void> saveRecentExam(
      String subjectId, int year, String? chapterId) async {
    try {
      emit(RecentExamLoading());
      final recentExam =
          await examRepo.saveRecentExam(subjectId, year, chapterId);
      emit(RecentExamLoaded(recentExam: recentExam));
    } catch (e) {
      emit(RecentExamError(e.toString()));
    }
  }
}
