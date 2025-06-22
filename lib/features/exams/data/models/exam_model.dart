import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:hive/hive.dart';

part 'exam_model.g.dart';

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

  @HiveField(7)
  @override
  final String? region;

  const ExamModel({
    required this.id,
    required this.subjectId,
    required this.year,
    required this.title,
    required this.totalQuestions,
    required this.durationMins,
    required this.chapters,
    this.region,
  }) : super(
            id: id,
            subjectId: subjectId,
            year: year,
            title: title,
            totalQuestions: totalQuestions,
            durationMins: durationMins,
            chapters: chapters,
            region: region);

  factory ExamModel.fromEntity(Exam exam) {
    return ExamModel(
      id: exam.id,
      subjectId: exam.subjectId,
      year: exam.year,
      title: exam.title,
      totalQuestions: exam.totalQuestions,
      durationMins: exam.durationMins,
      chapters:
          exam.chapters.map((e) => ExamChapterModel.fromEntity(e)).toList(),
      region: exam.region,
    );
  }
}

@HiveType(typeId: HiveTypeIds.chapter)
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

  ExamChapterModel({
    required this.id,
    required this.name,
    required this.questionCount,
  }) : super(id: id, name: name, questionCount: questionCount);

  factory ExamChapterModel.fromEntity(ExamChapter chapter) {
    return ExamChapterModel(
      id: chapter.id,
      name: chapter.name,
      questionCount: chapter.questionCount,
    );
  }
}
