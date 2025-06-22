import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'subject.dart';

class RecentExam extends Equatable {
  final Subject subject;
  final int year;
  final ExamChapter? chapter;
  final String? region;

  const RecentExam({
    required this.subject,
    required this.year,
    this.chapter,
    this.region,
  });

  @override
  List<Object?> get props => [subject, year, chapter, region];
}
