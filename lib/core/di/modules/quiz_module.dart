import 'package:injectable/injectable.dart';
import 'package:exam_app/features/quiz/data/repositories/question_repository_impl.dart';
import 'package:exam_app/features/quiz/domain/repositories/question_repository.dart';

@module
abstract class QuizModule {
  @singleton
  QuestionRepository questionRepository() => QuestionRepositoryImpl();
} 