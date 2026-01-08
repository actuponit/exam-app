import 'dart:io';

import 'package:dio/dio.dart';
import 'package:exam_app/core/constants/directory_constant.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/quiz/domain/models/question.dart';
import 'package:path_provider/path_provider.dart';

abstract class IQuestionsRemoteDatasource {
  Future<Map<String, List<Question>>> getQuestions(
      String userId, Function(int, int) onReceiveProgress);
  Future<List<String>> downloadImages(
    Map<String, String> urls,
  );
}

class QuestionsRemoteDatasource implements IQuestionsRemoteDatasource {
  final Dio dio;

  QuestionsRemoteDatasource({
    required this.dio,
  });

  @override
  Future<Map<String, List<Question>>> getQuestions(
      String userId, Function(int, int) onReceiveProgress) async {
    final response = await dio.post(
      'get-questions',
      data: {'user_id': userId},
      onReceiveProgress: onReceiveProgress,
    );

    final Map<String, dynamic> responseData = response.data['response'];
    // final Map<String, dynamic> responseData = response['response'];

    return responseData.map((subject, questions) {
      final List<Question> questionList = (questions as List)
          .map((q) => _mapToQuestion(q as Map<String, dynamic>))
          .toList();
      return MapEntry(subject, questionList);
    });
  }

  Question _mapToQuestion(Map<String, dynamic> json) {
    final choices = (json['choices'] as List).map((c) {
      if (c['choice_image_path'] != null &&
          c['choice_image_path'].toString().isNotEmpty) {
        c['choice_text'] += '\n\n![Choice Image](o_${c['id']})';
      }
      return Option(
        id: c['id'].toString(),
        text: c['choice_text'],
        image: c['choice_image_path'],
      );
    }).toList();

    final chapter = ExamChapter.fromJson(json['chapter']);
    final subject = Subject.fromJson(json['subject']);
    final isCOC = subject.name.toLowerCase().contains('coc');

    // Build question text with image if present
    String questionText = json['question_text'] ?? '';
    final questionImagePath = json['question_image_path'];
    if (questionImagePath != null && questionImagePath.toString().isNotEmpty) {
      questionText += '\n\n![Question Image](q_${json['id']})';
    }

    // Build explanation text with image if present
    String explanationText = json['explanation'] ?? '';
    final explanationImagePath = json['explanation_image_path'];

    final year = json['subject']?['year'].toString() ?? 'Unknown';

    return Question(
      id: json['id'].toString(),
      text: questionText,
      options: choices,
      correctOption: json['correct_choice_id'].toString(),
      explanation: explanationText,
      chapter:
          isCOC ? ExamChapter(id: year, questionCount: 0, name: year) : chapter,
      year: isCOC ? chapter.name : json['subject']?['year'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      subject: subject,
      region: json['subject']?['region'],
      image: explanationImagePath,
      imagePath: json['question_image_path'],
      explanationImagePath: json['explanation_image_path'],
    );
  }

  @override
  Future<List<String>> downloadImages(Map<String, String> urls) async {
    final List<String> downloadedImages = [];
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/images';
    if (!Directory(path).existsSync()) {
      Directory(path).createSync(recursive: true);
    }
    DirectoryConstant.images = path;

    final List<Future<dynamic>> downloadedFutures = [];
    for (final entry in urls.entries) {
      downloadedFutures.add(dio.download(entry.value, '$path/${entry.key}'));
    }
    await Future.wait(downloadedFutures);
    return downloadedImages;
  }
}
