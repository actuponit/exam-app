import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';

class Exam extends Equatable {
  final String id;
  final Subject subject;
  final int year;
  final bool isLocked;

  const Exam({
    required this.id,
    required this.subject,
    required this.year,
    required this.isLocked,
  });

  @override
  List<Object?> get props => [id, subject, year, isLocked];
} 