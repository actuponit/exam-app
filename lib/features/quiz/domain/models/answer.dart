import 'package:equatable/equatable.dart';
import 'package:exam_app/features/quiz/domain/models/question.dart';

class Answer extends Equatable {
  final Question question;
  final String selectedOption;
  final DateTime answeredAt;

  const Answer({
    required this.question,
    required this.selectedOption,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
        question,
        selectedOption,
        answeredAt,
      ];

  Answer copyWith({
    Question? questionId,
    String? selectedOption,
    DateTime? answeredAt,
  }) {
    return Answer(
      question: questionId ?? this.question,
      selectedOption: selectedOption ?? this.selectedOption,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}
