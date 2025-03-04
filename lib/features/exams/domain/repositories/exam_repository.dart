import 'package:dartz/dartz.dart';
import '../entities/exam.dart';
import '../entities/subject.dart';
import '../../../../core/error/failures.dart';

abstract class ExamRepository {
  Future<Either<Failure, Map<int, List<Exam>>>> getExamsByYear();
  Future<Either<Failure, Map<String, List<Exam>>>> getExamsBySubject();
  Future<Either<Failure, List<Subject>>> getSubjects();
} 