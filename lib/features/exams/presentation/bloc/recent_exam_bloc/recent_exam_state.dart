import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/recent_exam.dart';

abstract class RecentExamState extends Equatable {
  const RecentExamState();

  @override
  List<Object?> get props => [];
}

class RecentExamInitial extends RecentExamState {}

class RecentExamLoading extends RecentExamState {}

class RecentExamLoaded extends RecentExamState {
  final RecentExam? recentExam;

  const RecentExamLoaded({this.recentExam});

  @override
  List<Object?> get props => [recentExam];
}

class RecentExamError extends RecentExamState {
  final String message;

  const RecentExamError(this.message);

  @override
  List<Object?> get props => [message];
}
