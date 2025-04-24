import 'package:exam_app/features/exams/domain/entities/exam.dart';

abstract class ExamRepository {
  Future<List<Exam>> fetchExamsBySubject(String subjectId);
}
