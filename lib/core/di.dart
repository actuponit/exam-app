import 'package:get_it/get_it.dart';
import '../features/quiz/data/repositories/question_repository_impl.dart';
import '../features/quiz/domain/repositories/question_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(),
  );
} 