import 'package:dio/dio.dart';
import 'package:exam_app/core/services/hive_service.dart';
import 'package:exam_app/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:exam_app/features/notes/data/models/note_model.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../../features/notes/domain/repositories/notes_repository.dart';
import '../../../features/notes/presentation/cubit/notes_cubit.dart';

@module
abstract class NotesModule {
  @singleton
  Box<NotesListModel> notesBox(HiveService hiveService) => hiveService.notesBox;
  @singleton
  NotesLocalDataSource notesLocalDatasource(Box<NotesListModel> notesBox) =>
      NotesLocalDataSourceImpl(notesBox);

  @singleton
  NotesRemoteDataSource notesRemoteDatasource(Dio dio) =>
      NotesRemoteDataSourceImpl(dio: dio);

  @lazySingleton
  NotesRepository notesRepository(NotesLocalDataSource localDataSource) =>
      NotesRepositoryImpl(localDataSource: localDataSource);

  @factoryMethod
  NotesCubit notesCubit(NotesRepository repository) =>
      NotesCubit(repository: repository);
}
