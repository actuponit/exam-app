import 'package:exam_app/core/services/hive_service.dart';
import 'package:exam_app/features/exams/data/datasource/exam_local_datasource.dart';
import 'package:exam_app/features/exams/data/models/exam_model.dart';
import 'package:exam_app/features/exams/data/repositories/exam_repo_impl.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ExamModule {
  @singleton
  @Named('exams')
  Box<ExamModel> examsBox(HiveService hiveService) => hiveService.examsBox;

  @singleton
  IExamLocalDatasource examLocalDatasource(
    @Named('exams') Box<ExamModel> examsBox,
  ) =>
      ExamLocalDatasource(examsBox: examsBox);

  @singleton
  ExamRepository examRepository(IExamLocalDatasource localDatasource) =>
      ExamRepoImpl(localDatasource);

  @factoryMethod
  ExamBloc examBloc(ExamRepository repository) => ExamBloc(repository);
}
