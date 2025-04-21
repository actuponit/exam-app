import 'package:hive/hive.dart';
import '../../domain/entities/exam.dart';
import 'subject_model.dart';
import '../../../../core/constants/hive_constants.dart';

@HiveType(typeId: HiveTypeIds.exam)
class ExamModel extends Exam {
  @HiveField(0)
  @override
  final String id;

  @override
  @HiveField(2)
  final SubjectModel subject; // Embedded essential subject fields

  @HiveField(3)
  @override
  final int year;

  @HiveField(4)
  @override
  @override
  final bool isLocked;

  const ExamModel({
    required this.id,
    required this.subject,
    required this.year,
    required this.isLocked,
  }) : super(id: id, subject: subject, year: year, isLocked: isLocked);
  factory ExamModel.fromEntity(Exam exam, SubjectModel subject) {
    return ExamModel(
      id: exam.id,
      subject: subject,
      year: exam.year,
      isLocked: exam.isLocked,
    );
  }
}
