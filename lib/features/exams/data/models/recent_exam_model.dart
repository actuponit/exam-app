import 'package:hive/hive.dart';
import '../../domain/entities/recent_exam.dart';
import '../../../../core/constants/hive_constants.dart';
import 'subject_model.dart';
import 'exam_model.dart';

part 'recent_exam_model.g.dart';

@HiveType(typeId: HiveTypeIds.recentExam)
class RecentExamModel extends RecentExam {
  @HiveField(0)
  @override
  final SubjectModel subject;

  @HiveField(1)
  @override
  final int year;

  @HiveField(2)
  @override
  final ExamChapterModel? chapter;

  const RecentExamModel({
    required this.subject,
    required this.year,
    this.chapter,
  }) : super(
          subject: subject,
          year: year,
          chapter: chapter,
        );

  factory RecentExamModel.fromEntity(RecentExam exam) {
    return RecentExamModel(
      subject: SubjectModel.fromEntity(exam.subject),
      year: exam.year,
      chapter: exam.chapter != null
          ? ExamChapterModel.fromEntity(exam.chapter!)
          : null,
    );
  }
}
