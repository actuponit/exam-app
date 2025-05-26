import 'package:hive/hive.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/exams/data/models/subject_model.dart';

abstract class ISubjectLocalDatasource {
  Future<List<Subject>> getSubjects();
  Future<void> saveSubjects(List<Subject> subjects);
  Future<void> updateSubject(Subject subject);
  Future<void> clearSubjects();
  Future<Subject?> getSubject(String subjectId);
}

class SubjectLocalDatasource implements ISubjectLocalDatasource {
  final Box<SubjectModel> _subjectsBox;

  SubjectLocalDatasource({
    required Box<SubjectModel> subjectsBox,
  }) : _subjectsBox = subjectsBox;

  @override
  Future<List<Subject>> getSubjects() async {
    final subjectsData = _subjectsBox.values.toList();
    return subjectsData;
  }

  @override
  Future<void> saveSubjects(List<Subject> subjects) async {
    await _subjectsBox.clear();
    for (final subject in subjects) {
      await _subjectsBox.put(subject.id, SubjectModel.fromEntity(subject));
    }
  }

  @override
  Future<Subject?> getSubject(String subjectId) async {
    return _subjectsBox.get(subjectId);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _subjectsBox.put(subject.id, SubjectModel.fromEntity(subject));
  }

  @override
  Future<void> clearSubjects() async {
    await _subjectsBox.clear();
  }
}
