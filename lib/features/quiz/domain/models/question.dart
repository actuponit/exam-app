import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String text;
  final List<String> options;
  final String correctOption;
  final String? explanation;
  final String? chapter;
  final int? year;
  final DateTime createdAt;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOption,
    this.explanation,
    this.chapter,
    this.year,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        options,
        correctOption,
        explanation,
        chapter,
        year,
        createdAt,
      ];

  Question copyWith({
    String? id,
    String? text,
    List<String>? options,
    String? correctOption,
    String? explanation,
    String? chapter,
    int? year,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctOption: correctOption ?? this.correctOption,
      explanation: explanation ?? this.explanation,
      chapter: chapter ?? this.chapter,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Option extends Equatable {
  final String id;
  final String text;

  const Option({
    required this.id,
    required this.text,
  });

  @override
  List<Object?> get props => [id, text];
}

class Answer extends Equatable {
  final String questionId;
  final String selectedOptionId;
  final DateTime answeredAt;

  const Answer({
    required this.questionId,
    required this.selectedOptionId,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [questionId, selectedOptionId, answeredAt];
} 