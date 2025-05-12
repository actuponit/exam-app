import 'package:hive/hive.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/data/models/exam_model.dart';
import 'package:injectable/injectable.dart';

abstract class IExamLocalDatasource {
  Future<List<Exam>> getExams();
  Future<void> saveExams(List<Exam> exams);
  Future<void> updateExam(Exam exam);
  Future<void> clearExams();
}

class ExamLocalDatasource implements IExamLocalDatasource {
  final Box<ExamModel> _examsBox;

  ExamLocalDatasource({
    @Named('exams') required Box<ExamModel> examsBox,
  }) : _examsBox = examsBox;

  @override
  Future<List<Exam>> getExams() async {
    return _examsBox.values.toList();
  }

  @override
  Future<void> clearExams() async {
    await _examsBox.clear();
  }

  @override
  Future<void> saveExams(List<Exam> exams) async {
    await _examsBox.clear();
    for (final exam in exams) {
      await _examsBox.put(exam.id, ExamModel.fromEntity(exam));
    }
  }

  @override
  Future<void> updateExam(Exam exam) async {
    await _examsBox.put(exam.id, ExamModel.fromEntity(exam));
  }
}
