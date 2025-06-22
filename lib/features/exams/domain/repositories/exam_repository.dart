import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/recent_exam.dart';

abstract class ExamRepository {
  Future<List<Exam>> fetchExamsBySubject(String subjectId, {String? region});
  Future<RecentExam> saveRecentExam(
      String subjectId, int year, String? chapterId, String? region);
  Future<RecentExam?> getRecentExam();
  Future<Map<String, Set<String>>> fetchRegions();
}
