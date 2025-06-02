import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:exam_app/features/exams/data/models/exam_model.dart';
import 'package:exam_app/features/exams/data/models/subject_model.dart';
import 'package:exam_app/features/quiz/domain/models/question.dart';
import 'package:hive/hive.dart';

part 'question_model.g.dart';

@HiveType(typeId: HiveTypeIds.question)
class QuestionModel extends Question {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String text;

  @HiveField(2)
  @override
  final List<OptionModel> options;

  @HiveField(3)
  @override
  final String correctOption;

  @HiveField(4)
  @override
  final String? explanation;

  @HiveField(5)
  @override
  final int? year;

  @HiveField(6)
  @override
  final DateTime createdAt;

  @HiveField(7)
  @override
  final bool isAttempted;

  @HiveField(8)
  @override
  final ExamChapterModel chapter;

  @HiveField(9)
  @override
  final SubjectModel subject;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOption,
    this.explanation,
    this.year,
    required this.createdAt,
    this.isAttempted = false,
    required this.chapter,
    required this.subject,
  }) : super(
          id: id,
          text: text,
          options: options,
          correctOption: correctOption,
          explanation: explanation,
          year: year,
          createdAt: createdAt,
          isAttempted: isAttempted,
          chapter: chapter,
          subject: subject,
        );

  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      text: question.text,
      options: question.options.map((e) => OptionModel.fromEntity(e)).toList(),
      correctOption: question.correctOption,
      explanation: question.explanation,
      year: question.year,
      createdAt: question.createdAt,
      isAttempted: question.isAttempted,
      chapter: ExamChapterModel.fromEntity(question.chapter),
      subject: SubjectModel.fromEntity(question.subject),
    );
  }
}

@HiveType(typeId: HiveTypeIds.option)
class OptionModel extends Option {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String text;

  const OptionModel({
    required this.id,
    required this.text,
  }) : super(id: id, text: text);

  factory OptionModel.fromEntity(Option option) {
    return OptionModel(
      id: option.id,
      text: option.text,
    );
  }
}
