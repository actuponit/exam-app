import 'package:exam_app/features/exams/data/repositories/exam_repo_impl.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ExamModule {
  @singleton
  ExamRepository examRepository() => ExamRepoImpl();
}
