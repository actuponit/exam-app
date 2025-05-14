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
      // final Map<String, dynamic> response = {
      //   "status": "success",
      //   "response": {
      //     "physics": [
      //       {
      //         "id": 15,
      //         "correct_choice_id": 67,
      //         "subject_id": 2,
      //         "year_group_id": 2,
      //         "question_text":
      //             "A car accelerates uniformly from rest to a speed of 20 m/s in 5 seconds. What is its acceleration?",
      //         "question_image_path": null,
      //         "formula": null,
      //         "explanation":
      //             "Explanation:\n✅Using the equation of motion: v = u + at\nwhere v = final velocity, u = initial velocity, a = acceleration, t = time\n\n🙌Step-by-step Calculation:\n20 = 0 + a(5)\n20 = 5a\na = 4 m/s²\n\nFinal Answer:\nThe acceleration is 4 m/s².",
      //         "explanation_image_path": null,
      //         "created_at": "2025-04-20T17:57:52.000000Z",
      //         "updated_at": "2025-05-02T15:51:57.000000Z",
      //         "type_id": 3,
      //         "chapter_id": 7,
      //         "duration": null,
      //         "answer_id": null,
      //         "choices": [
      //           {
      //             "id": 67,
      //             "question_id": 15,
      //             "choice_text": "4 m/s²",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 68,
      //             "question_id": 15,
      //             "choice_text": "5 m/s²",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 69,
      //             "question_id": 15,
      //             "choice_text": "3 m/s²",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 70,
      //             "question_id": 15,
      //             "choice_text": "2 m/s²",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           }
      //         ],
      //         "subject": {
      //           "id": 2,
      //           "name": "physics",
      //           "type_id": null,
      //           "year": "",
      //           "created_at": "2025-03-18T11:06:33.000000Z",
      //           "updated_at": "2025-03-18T11:06:33.000000Z",
      //           "default_duration": null,
      //           "region": null
      //         },
      //         "chapter": {
      //           "name": "Chapter-1: Preliminaries",
      //           "description": null,
      //           "image": null,
      //           "id": 7,
      //           "created_at": "2025-04-20T12:21:56.000000Z",
      //           "updated_at": "2025-04-20T12:21:56.000000Z"
      //         },
      //         "year_group": {
      //           "id": 2,
      //           "year": 2015,
      //           "created_at": "2025-03-18T14:23:16.000000Z",
      //           "updated_at": "2025-03-18T14:23:16.000000Z"
      //         }
      //       },
      //       {
      //         "id": 16,
      //         "correct_choice_id": 71,
      //         "subject_id": 2,
      //         "year_group_id": 2,
      //         "question_text":
      //             "What is the kinetic energy of a 2 kg object moving at 3 m/s?",
      //         "question_image_path": null,
      //         "formula": null,
      //         "explanation":
      //             "Explanation:\n✅Using the kinetic energy formula: KE = ½mv²\nwhere m = mass, v = velocity\n\n🙌Step-by-step Calculation:\nKE = ½(2)(3)²\nKE = ½(2)(9)\nKE = 9 J\n\nFinal Answer:\nThe kinetic energy is 9 Joules.",
      //         "explanation_image_path": null,
      //         "created_at": "2025-04-20T17:57:52.000000Z",
      //         "updated_at": "2025-05-02T15:51:57.000000Z",
      //         "type_id": 3,
      //         "chapter_id": 8,
      //         "duration": null,
      //         "answer_id": null,
      //         "choices": [
      //           {
      //             "id": 71,
      //             "question_id": 16,
      //             "choice_text": "9 J",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 72,
      //             "question_id": 16,
      //             "choice_text": "6 J",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 73,
      //             "question_id": 16,
      //             "choice_text": "12 J",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 74,
      //             "question_id": 16,
      //             "choice_text": "18 J",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           }
      //         ],
      //         "subject": {
      //           "id": 2,
      //           "name": "physics",
      //           "type_id": null,
      //           "year": "",
      //           "created_at": "2025-03-18T11:06:33.000000Z",
      //           "updated_at": "2025-03-18T11:06:33.000000Z",
      //           "default_duration": null,
      //           "region": null
      //         },
      //         "chapter": {
      //           "name": "Chapter-2: Energy and Work",
      //           "description": null,
      //           "image": null,
      //           "id": 8,
      //           "created_at": "2025-04-20T12:21:56.000000Z",
      //           "updated_at": "2025-04-20T12:21:56.000000Z"
      //         },
      //         "year_group": {
      //           "id": 2,
      //           "year": 2015,
      //           "created_at": "2025-03-18T14:23:16.000000Z",
      //           "updated_at": "2025-03-18T14:23:16.000000Z"
      //         }
      //       }
      //     ],
      //     "mathematics": [
      //       {
      //         "id": 17,
      //         "correct_choice_id": 75,
      //         "subject_id": 1,
      //         "year_group_id": 2,
      //         "question_text": "Solve the quadratic equation: x² + 5x + 6 = 0",
      //         "question_image_path": null,
      //         "formula": null,
      //         "explanation":
      //             "Explanation:\n✅Using the quadratic formula: x = (-b ± √(b² - 4ac))/2a\nwhere a = 1, b = 5, c = 6\n\n🙌Step-by-step Calculation:\nx = (-5 ± √(25 - 24))/2\nx = (-5 ± √1)/2\nx = (-5 ± 1)/2\n\nTherefore:\nx = (-5 + 1)/2 = -2\nx = (-5 - 1)/2 = -3\n\nFinal Answer:\nThe solutions are x = -2 and x = -3",
      //         "explanation_image_path": null,
      //         "created_at": "2025-04-20T17:57:52.000000Z",
      //         "updated_at": "2025-05-02T15:51:57.000000Z",
      //         "type_id": 3,
      //         "chapter_id": 9,
      //         "duration": null,
      //         "answer_id": null,
      //         "choices": [
      //           {
      //             "id": 75,
      //             "question_id": 17,
      //             "choice_text": "x = -2, -3",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 76,
      //             "question_id": 17,
      //             "choice_text": "x = 2, 3",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 77,
      //             "question_id": 17,
      //             "choice_text": "x = -1, -4",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           },
      //           {
      //             "id": 78,
      //             "question_id": 17,
      //             "choice_text": "x = 1, 4",
      //             "choice_image_path": null,
      //             "formula": "",
      //             "created_at": "2025-05-02T15:51:57.000000Z",
      //             "updated_at": "2025-05-02T15:51:57.000000Z"
      //           }
      //         ],
      //         "subject": {
      //           "id": 1,
      //           "name": "mathematics",
      //           "type_id": null,
      //           "year": "",
      //           "created_at": "2025-03-18T11:06:33.000000Z",
      //           "updated_at": "2025-03-18T11:06:33.000000Z",
      //           "default_duration": null,
      //           "region": null
      //         },
      //         "chapter": {
      //           "name": "Chapter-1: Quadratic Equations",
      //           "description": null,
      //           "image": null,
      //           "id": 9,
      //           "created_at": "2025-04-20T12:21:56.000000Z",
      //           "updated_at": "2025-04-20T12:21:56.000000Z"
      //         },
      //         "year_group": {
      //           "id": 2,
      //           "year": 2015,
      //           "created_at": "2025-03-18T14:23:16.000000Z",
      //           "updated_at": "2025-03-18T14:23:16.000000Z"
      //         }
      //       }
      //     ]
      //   }
      // };

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
      year: json['year_group']?['year'],
      createdAt: DateTime.parse(json['created_at']),
      subject: subject,
    );
  }
}
