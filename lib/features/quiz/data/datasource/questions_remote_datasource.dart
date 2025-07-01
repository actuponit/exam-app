import 'package:dio/dio.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/quiz/domain/models/question.dart';

abstract class IQuestionsRemoteDatasource {
  Future<Map<String, List<Question>>> getQuestions(String userId);
}

class QuestionsRemoteDatasource implements IQuestionsRemoteDatasource {
  final Dio dio;

  QuestionsRemoteDatasource({
    required this.dio,
  });

  @override
  Future<Map<String, List<Question>>> getQuestions(String userId) async {
    try {
      final response = await dio.post(
        'get-questions',
        data: {'user_id': userId},
      );

      final Map<String, dynamic> responseData = response.data['response'];
      // final Map<String, dynamic> responseData = response['response'];

      return responseData.map((subject, questions) {
        final List<Question> questionList = (questions as List)
            .map((q) => _mapToQuestion(q as Map<String, dynamic>))
            .toList();
        return MapEntry(subject, questionList);
      });
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        error: 'Error fetching questions: ${e.message}',
      );
    }
  }

  Question _mapToQuestion(Map<String, dynamic> json) {
    final choices = (json['choices'] as List)
        .map((c) => Option(
              id: c['id'].toString(),
              text: c['choice_text'],
              image: c['choice_image_path'],
            ))
        .toList();

    final chapter = ExamChapter.fromJson(json['chapter']);
    final subject = Subject.fromJson(json['subject']);
    return Question(
      id: json['id'].toString(),
      text: json['question_text'],
      options: choices,
      correctOption: json['correct_choice_id'].toString(),
      explanation: json['explanation'],
      chapter: chapter,
      year: int.tryParse(json['subject']?['year']),
      createdAt: DateTime.parse(json['created_at']),
      subject: subject,
      region: json['subject']?['region'],
      image: json['question_image_path'],
    );
  }
}
