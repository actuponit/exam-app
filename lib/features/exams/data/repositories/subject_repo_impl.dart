import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';

class SubjectRepoImpl implements SubjectRepository {
  final ISubjectLocalDatasource _localDatasource;

  SubjectRepoImpl(this._localDatasource);

  @override
  Future<List<Subject>> fetchSubjects() async {
    return _localDatasource.getSubjects();
  }
}
