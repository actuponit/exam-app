import 'package:dartz/dartz.dart';
import '../repositories/exam_repository.dart';
import '../entities/exam.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetExamsBySubject implements UseCase<Map<String, List<Exam>>, NoParams> {
  final ExamRepository repository;

  GetExamsBySubject(this.repository);

  @override
  Future<Either<Failure, Map<String, List<Exam>>>> call(NoParams params) {
    return repository.getExamsBySubject();
  }
} 