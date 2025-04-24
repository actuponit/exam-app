import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';

class ExamRepoImpl implements ExamRepository {
  @override
  Future<List<Exam>> fetchExamsBySubject(String subjectId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _dummyExams.where((exam) => exam.subjectId == subjectId).toList();
  }

  final List<Exam> _dummyExams = [
    Exam(
      id: 'exam1',
      subjectId: '1',
      year: 2023,
      title: 'Mid-Year Math Exam',
      totalQuestions: 30,
      durationMins: 60,
      chapters: [
        ExamChapter(id: 'chap1', name: 'Algebra', questionCount: 10, order: 1),
        ExamChapter(id: 'chap2', name: 'Geometry', questionCount: 20, order: 2),
      ],
    ),
    Exam(
      id: 'exam2',
      subjectId: '1',
      year: 2022,
      title: 'Final Math Exam',
      totalQuestions: 40,
      durationMins: 90,
      chapters: [
        ExamChapter(id: 'chap1', name: 'Algebra', questionCount: 15, order: 1),
        ExamChapter(
            id: 'chap3', name: 'Trigonometry', questionCount: 25, order: 3),
      ],
    ),
    Exam(
      id: 'exam3',
      subjectId: '1',
      year: 2023,
      title: 'Mid-Year Physics Exam',
      totalQuestions: 35,
      durationMins: 75,
      chapters: [
        ExamChapter(
            id: 'chap4', name: 'Kinematics', questionCount: 20, order: 1),
        ExamChapter(id: 'chap5', name: 'Dynamics', questionCount: 15, order: 2),
      ],
    ),
    Exam(
      id: '1',
      subjectId: '2',
      year: 2022,
      title: 'Final Physics Exam',
      totalQuestions: 45,
      durationMins: 90,
      chapters: [
        ExamChapter(
            id: 'chap4', name: 'Kinematics', questionCount: 25, order: 1),
        ExamChapter(id: 'chap6', name: 'Waves', questionCount: 20, order: 3),
      ],
    ),
  ];
}
