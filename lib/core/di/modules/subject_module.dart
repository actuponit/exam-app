import 'package:exam_app/features/exams/data/repositories/subject_repo_impl.dart';
import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:injectable/injectable.dart';

@module
abstract class SubjectModule {
  @singleton
  SubjectRepository subjectRepository() => SubjectRepoImpl();

  @factoryMethod
  SubjectBloc subjectBloc(SubjectRepository repository) =>
      SubjectBloc(repository);
}
