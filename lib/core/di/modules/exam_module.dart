import 'package:exam_app/core/services/hive_service.dart';
import 'package:exam_app/features/exams/data/datasource/exam_local_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/recent_exam_local_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/exams/data/models/exam_model.dart';
import 'package:exam_app/features/exams/data/models/recent_exam_model.dart';
import 'package:exam_app/features/exams/data/repositories/exam_repo_impl.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/exams/presentation/bloc/recent_exam_bloc/recent_exam_cubit.dart';
import 'package:exam_app/features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ExamModule {
  @singleton
  @Named('exams')
  Box<ExamModel> examsBox(HiveService hiveService) => hiveService.examsBox;

  @singleton
  @Named('recentExams')
  Box<RecentExamModel> recentExamsBox(HiveService hiveService) =>
      hiveService.recentExamsBox;

  @singleton
  IRecentExamLocalDatasource recentExamLocalDatasource(
    @Named('recentExams') Box<RecentExamModel> recentExamsBox,
  ) =>
      RecentExamLocalDatasource(recentExamsBox: recentExamsBox);

  @singleton
  IExamLocalDatasource examLocalDatasource(
    @Named('exams') Box<ExamModel> examsBox,
  ) =>
      ExamLocalDatasource(examsBox: examsBox);

  @singleton
  ExamRepository examRepository(
    IExamLocalDatasource localDatasource,
    IRecentExamLocalDatasource recentExamLocalDatasource,
    ISubjectLocalDatasource subjectLocalDatasource,
  ) =>
      ExamRepoImpl(
          localDatasource, recentExamLocalDatasource, subjectLocalDatasource);

  @factoryMethod
  ExamBloc examBloc(ExamRepository repository) => ExamBloc(repository);

  @factoryMethod
  RecentExamCubit recentExamCubit(ExamRepository examRepo) =>
      RecentExamCubit(examRepo);
}
