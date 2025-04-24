import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: HiveTypeIds.exam)
class ExamModel extends Exam {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String subjectId;

  @HiveField(2)
  @override
  final int year;

  @HiveField(3)
  @override
  final String title;

  @HiveField(4)
  @override
  final int totalQuestions;

  @HiveField(5)
  @override
  final int durationMins;

  @HiveField(6)
  @override
  final List<ExamChapterModel> chapters;

  const ExamModel({
    required this.id,
    required this.subjectId,
    required this.year,
    required this.title,
    required this.totalQuestions,
    required this.durationMins,
    required this.chapters,
  }) : super(
            id: id,
            subjectId: subjectId,
            year: year,
            title: title,
            totalQuestions: totalQuestions,
            durationMins: durationMins,
            chapters: chapters);
}

@HiveType(typeId: 2)
class ExamChapterModel extends ExamChapter {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final int questionCount;

  @HiveField(3)
  @override
  final int order;

  ExamChapterModel({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.order,
  }) : super(id: id, name: name, questionCount: questionCount, order: order);
}
