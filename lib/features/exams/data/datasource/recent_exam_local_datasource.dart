import 'package:hive/hive.dart';
import 'package:exam_app/features/exams/domain/entities/recent_exam.dart';
import 'package:exam_app/features/exams/data/models/recent_exam_model.dart';
import 'package:injectable/injectable.dart';

abstract class IRecentExamLocalDatasource {
  Future<RecentExam?> getRecentExams();
  Future<void> saveRecentExam(RecentExam exam);
  Future<void> clearRecentExams();
}

class RecentExamLocalDatasource implements IRecentExamLocalDatasource {
  final Box<RecentExamModel> _recentExamsBox;

  RecentExamLocalDatasource({
    @Named('recentExams') required Box<RecentExamModel> recentExamsBox,
  }) : _recentExamsBox = recentExamsBox;

  @override
  Future<RecentExam?> getRecentExams() async {
    return _recentExamsBox.get("recent_exam");
  }

  @override
  Future<void> saveRecentExam(RecentExam exam) async {
    await _recentExamsBox.put("recent_exam", RecentExamModel.fromEntity(exam));
  }

  @override
  Future<void> clearRecentExams() async {
    await _recentExamsBox.clear();
  }
}
