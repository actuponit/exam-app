import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';

part 'subject_events.dart';
part 'subject_states.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository subjectRepository;
  final ExamRepository examRepository;

  Map<String, List<Subject>> regionSubjects = {};

  SubjectBloc(this.subjectRepository, this.examRepository)
      : super(SubjectInitial()) {
    on<LoadSubjects>(_onFetchSubjects);
    on<FilterSubjects>(_onFilterSubjects);
  }

  Future<void> _onFilterSubjects(
      FilterSubjects event, Emitter<SubjectState> emit) async {
    emit(SubjectLoading());
    final subjects = regionSubjects[event.region];
    emit(SubjectLoaded(subjects!, event.region, regionSubjects.keys.toList()));
  }

  Future<void> _onFetchSubjects(
      LoadSubjects event, Emitter<SubjectState> emit) async {
    emit(SubjectLoading());
    try {
      final subjects = await subjectRepository.fetchSubjects();
      final regions = await examRepository.fetchRegions();
      regionSubjects = {};
      Map<String, Subject> subjectsMap = {};
      for (var subject in subjects) {
        subjectsMap[subject.name] = subject;
      }
      for (var region in regions.keys) {
        for (var subjectId in regions[region]!) {
          regionSubjects.putIfAbsent(region, () => []);
          regionSubjects[region]!.add(subjectsMap[subjectId]!);
        }
      }
      final allRegions = regions.keys.toList();
      final String initalRegion = allRegions.first;
      emit(SubjectLoaded(
          regionSubjects[initalRegion]!, initalRegion, allRegions));
    } catch (e) {
      emit(const SubjectError('Failed to load subjects'));
    }
  }
}
