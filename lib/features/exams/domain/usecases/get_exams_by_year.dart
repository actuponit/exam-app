import 'package:dartz/dartz.dart';
import '../repositories/exam_repository.dart';
import '../entities/exam.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetExamsByYear implements UseCase<Map<int, List<Exam>>, NoParams> {
  final ExamRepository repository;

  GetExamsByYear(this.repository);

  @override
  Future<Either<Failure, Map<int, List<Exam>>>> call(NoParams params) {
    return repository.getExamsByYear();
  }
} 