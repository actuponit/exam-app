import 'package:exam_app/features/quiz/data/models/question_model.dart';
import 'package:hive/hive.dart';
import 'package:exam_app/features/quiz/domain/models/question.dart';

abstract class IQuestionsLocalDatasource {
  Future<List<Question>> getQuestions();
  Future<void> saveQuestions(List<Question> questions);
  Future<void> updateQuestion(Question question);
  Future<void> clearQuestions();
}

class QuestionsLocalDatasource implements IQuestionsLocalDatasource {
  final Box<QuestionModel> _questionsBox;

  QuestionsLocalDatasource({
    required Box<QuestionModel> questionsBox,
  }) : _questionsBox = questionsBox;

  @override
  Future<List<Question>> getQuestions() async {
    return _questionsBox.values.toList();
  }

  @override
  Future<void> saveQuestions(List<Question> questions) async {
    await _questionsBox.clear();
    for (final question in questions) {
      await _questionsBox.put(question.id, question.toModel());
    }
  }

  @override
  Future<void> updateQuestion(Question question) async {
    await _questionsBox.put(question.id, question.toModel());
  }

  @override
  Future<void> clearQuestions() async {
    await _questionsBox.clear();
  }
}
