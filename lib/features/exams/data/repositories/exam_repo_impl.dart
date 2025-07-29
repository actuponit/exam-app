import 'package:exam_app/features/exams/data/datasource/exam_local_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/recent_exam_local_datasource.dart';
import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/recent_exam.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';

class ExamRepoImpl implements ExamRepository {
  final IExamLocalDatasource _localDatasource;
  final IRecentExamLocalDatasource _recentExamLocalDatasource;
  final ISubjectLocalDatasource _subjectLocalDatasource;

  ExamRepoImpl(this._localDatasource, this._recentExamLocalDatasource,
      this._subjectLocalDatasource);

  @override
  Future<List<Exam>> fetchExamsBySubject(
    String subjectId, {
    String? region,
  }) async {
    final exams = await _localDatasource.getExams();
    if (region == null) {
      return exams.where((exam) => exam.subjectId == subjectId).toList()
        ..sort((a, b) => b.year.compareTo(a.year));
    } else {
      return exams
          .where((exam) => exam.subjectId == subjectId && exam.region == region)
          .toList()
        ..sort((a, b) => b.year.compareTo(a.year));
    }
  }

  @override
  Future<Map<String, Set<String>>> fetchRegions() async {
    final exams = await _localDatasource.getExams();
    Map<String, Set<String>> regions = {};
    for (var exam in exams) {
      regions.putIfAbsent(exam.region ?? "", () => <String>{});
      regions[exam.region ?? ""]!.add(exam.subjectId);
    }
    return regions;
  }

  @override
  Future<RecentExam?> getRecentExam() async {
    return _recentExamLocalDatasource.getRecentExams();
  }

  @override
  Future<RecentExam> saveRecentExam(
      String subjectId, int year, String? chapterId, String? region) async {
    final subject = await _subjectLocalDatasource.getSubject(subjectId);
    final exams = await fetchExamsBySubject(subjectId);
    final ExamChapter? chapter = chapterId != null
        ? exams
            .firstWhere((exam) => exam.year == year)
            .chapters
            .firstWhere((chapter) => chapter.id == chapterId)
        : null;
    final recentExam = RecentExam(
      subject: subject!,
      year: year,
      chapter: chapter,
      region: region,
    );
    await _recentExamLocalDatasource.saveRecentExam(recentExam);
    return recentExam;
  }
}
