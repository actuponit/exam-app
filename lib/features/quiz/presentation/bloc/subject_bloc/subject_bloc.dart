import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';

part 'subject_events.dart';
part 'subject_states.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository subjectRepository;

  SubjectBloc(this.subjectRepository) : super(SubjectInitial()) {
    on<LoadSubjects>(_onFetchSubjects);
  }

  Future<void> _onFetchSubjects(
      LoadSubjects event, Emitter<SubjectState> emit) async {
    emit(SubjectLoading());
    try {
      final subjects = await subjectRepository.fetchSubjects();
      emit(SubjectLoaded(subjects));
    } catch (e) {
      emit(const SubjectError('Failed to load subjects'));
    }
  }
}
