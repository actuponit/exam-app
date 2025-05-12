import 'package:exam_app/features/exams/data/datasource/subject_local_datasource.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';
import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';

class SubjectRepoImpl implements SubjectRepository {
  final ISubjectLocalDatasource _localDatasource;

  SubjectRepoImpl(this._localDatasource);

  @override
  Future<List<Subject>> fetchSubjects() async {
    final data = [
      {
        'id': '1',
        'name': 'Mathematics',
        'icon': 'book',
        'progress': 0.75,
      },
      {
        'id': '2',
        'name': 'Physics',
        'icon': 'calculate',
        'progress': 0.50,
      },
      {
        'id': '3',
        'name': 'Chemistry',
        'icon': 'flask',
        'progress': 0.25,
      },
      {
        'id': '4',
        'name': 'Biology',
        'icon': 'leaf',
        'progress': 0.90,
      },
      {
        'id': '5',
        'name': 'History',
        'icon': 'history',
        'progress': 0.60,
      },
    ];

    // await Future.delayed(const Duration(seconds: 5));

    return _localDatasource.getSubjects();
  }
}
