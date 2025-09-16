import 'package:injectable/injectable.dart';
import '../../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../../features/notes/domain/repositories/notes_repository.dart';
import '../../../features/notes/presentation/cubit/notes_cubit.dart';

@module
abstract class NotesModule {
  @lazySingleton
  NotesLocalDataSource get notesLocalDataSource => NotesLocalDataSourceImpl();

  @lazySingleton
  NotesRepository notesRepository(NotesLocalDataSource localDataSource) =>
      NotesRepositoryImpl(localDataSource: localDataSource);

  @factoryMethod
  NotesCubit notesCubit(NotesRepository repository) =>
      NotesCubit(repository: repository);
}
