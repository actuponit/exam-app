import 'package:exam_app/core/services/hive_service.dart';
import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/exams/data/models/subject_model.dart';
import 'package:exam_app/features/exams/data/repositories/subject_repo_impl.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@module
abstract class SubjectModule {
  @singleton
  Box<SubjectModel> subjectsBox(HiveService hiveService) =>
      hiveService.subjectsBox;

  @singleton
  ISubjectLocalDatasource subjectLocalDatasource(
    Box<SubjectModel> subjectsBox,
  ) =>
      SubjectLocalDatasource(subjectsBox: subjectsBox);

  @singleton
  SubjectRepository subjectRepository(
          ISubjectLocalDatasource localDatasource) =>
      SubjectRepoImpl(localDatasource);

  @factoryMethod
  SubjectBloc subjectBloc(
          SubjectRepository repository, ExamRepository examRepository) =>
      SubjectBloc(repository, examRepository);
}
