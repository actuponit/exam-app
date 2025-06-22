import '../models/question.dart';
import '../models/answer.dart' as models;

abstract class QuestionRepository {
  Future<List<Question>> getQuestions({
    required String subjectId,
    String? chapterId,
    required int year,
    String? region,
  });

  Future<void> saveAnswer(models.Answer answer);
  Future<List<models.Answer>> getSavedAnswers(List<String> questionIds);
  Future<void> getAllQuestions({bool ensureBackend = false});
}
