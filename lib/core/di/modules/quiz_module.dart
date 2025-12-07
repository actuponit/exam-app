import 'package:dio/dio.dart';
import 'package:exam_app/core/constants/directory_constant.dart';
import 'package:exam_app/core/services/hive_service.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/exams/data/datasource/exam_local_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:exam_app/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:exam_app/features/quiz/data/models/question_model.dart';
import 'package:exam_app/features/quiz/data/services/image_download_service_impl.dart';
import 'package:exam_app/features/quiz/domain/services/image_download_service.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:exam_app/features/quiz/data/datasource/questions_local_datasource.dart';
import 'package:exam_app/features/quiz/data/datasource/questions_remote_datasource.dart';
import 'package:exam_app/features/quiz/data/repositories/question_repository_impl.dart';
import 'package:exam_app/features/quiz/domain/repositories/question_repository.dart';

@module
abstract class QuizModule {
  @singleton
  Box<QuestionModel> questionsBox(HiveService hiveService) =>
      hiveService.questionsBox;

  @singleton
  IQuestionsLocalDatasource questionsLocalDatasource(
          Box<QuestionModel> questionsBox) =>
      QuestionsLocalDatasource(questionsBox: questionsBox);

  @singleton
  IQuestionsRemoteDatasource questionsRemoteDatasource(
    Dio dio,
    IQuestionsLocalDatasource localDatasource,
  ) =>
      QuestionsRemoteDatasource(
        dio: dio,
      );

  @singleton
  ImageDownloadService imageDownloadService() {
    return ImageDownloadServiceImpl(
      downloadDirectory: DirectoryConstant.images,
    );
  }

  @singleton
  QuestionRepository questionRepository(
    IQuestionsLocalDatasource localDatasource,
    IQuestionsRemoteDatasource remoteDatasource,
    ISubjectLocalDatasource subjectLocalDatasource,
    IExamLocalDatasource examLocalDatasource,
    LocalAuthDataSource authLocalDatasource,
    NotesLocalDataSource notesLocalDatasource,
    NotesRemoteDataSource notesRemoteDataSource,
    ImageDownloadService imageDownloadService,
  ) =>
      QuestionRepositoryImpl(
        localDatasource: localDatasource,
        remoteDatasource: remoteDatasource,
        subjectLocalDatasource: subjectLocalDatasource,
        examLocalDatasource: examLocalDatasource,
        authLocalDatasource: authLocalDatasource,
        notesLocalDatasource: notesLocalDatasource,
        notesRemoteDataSource: notesRemoteDataSource,
        imageDownloadService: imageDownloadService,
      );
}
