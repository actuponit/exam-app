import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'subject.dart';

class RecentExam extends Equatable {
  final Subject subject;
  final int year;
  final ExamChapter? chapter;

  const RecentExam({
    required this.subject,
    required this.year,
    this.chapter,
  });

  @override
  List<Object?> get props => [subject, year, chapter];
}
