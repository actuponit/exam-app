import 'package:exam_app/features/exams/domain/entities/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> fetchSubjects();
}
