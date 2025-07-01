import 'package:equatable/equatable.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/exams/domain/entities/subject.dart';

class Question extends Equatable {
  final String id;
  final String text;
  final List<Option> options;
  final String correctOption;
  final String? explanation;
  final int? year;
  final DateTime createdAt;
  final bool isAttempted;
  final ExamChapter chapter;
  final Subject subject;
  final String? image;
  final String? region;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOption,
    this.explanation,
    this.year,
    required this.createdAt,
    this.isAttempted = false,
    required this.chapter,
    required this.subject,
    this.image,
    this.region,
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
        image,
        region,
      ];

  Question copyWith({
    String? id,
    String? text,
    List<Option>? options,
    String? correctOption,
    String? explanation,
    ExamChapter? chapter,
    int? year,
    DateTime? createdAt,
    bool? isAttempted,
    Subject? subject,
    String? region,
    String? image,
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
      isAttempted: isAttempted ?? this.isAttempted,
      subject: subject ?? this.subject,
      region: region ?? this.region,
      image: image ?? this.image,
    );
  }
}

class Option extends Equatable {
  final String id;
  final String text;
  final String? image;

  const Option({
    required this.id,
    required this.text,
    this.image,
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
