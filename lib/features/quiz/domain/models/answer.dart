import 'package:equatable/equatable.dart';

class Answer extends Equatable {
  final String questionId;
  final String selectedOption;
  final DateTime answeredAt;

  const Answer({
    required this.questionId,
    required this.selectedOption,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
        questionId,
        selectedOption,
        answeredAt,
      ];

  Answer copyWith({
    String? questionId,
    String? selectedOption,
    DateTime? answeredAt,
  }) {
    return Answer(
      questionId: questionId ?? this.questionId,
      selectedOption: selectedOption ?? this.selectedOption,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
} 