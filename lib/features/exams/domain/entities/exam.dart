import 'package:equatable/equatable.dart';

class Exam extends Equatable {
  final String id;
  final String subjectId;
  final int year;
  final String title;
  final int totalQuestions;
  final int durationMins;
  final List<ExamChapter> chapters;
  final String? region;

  const Exam({
    required this.id,
    required this.subjectId,
    required this.year,
    required this.title,
    required this.totalQuestions,
    required this.durationMins,
    required this.chapters,
    this.region,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      subjectId: json['subjectId'],
      year: json['year'],
      title: json['title'],
      totalQuestions: json['totalQuestions'],
      durationMins: json['durationMins'],
      chapters: (json['chapters'] as List)
          .map((c) => ExamChapter.fromJson(c))
          .toList(),
      region: json['region'],
    );
  }

  bool containsChapter(String chapterId) {
    return chapters.any((c) => c.id == chapterId);
  }

  @override
  List<Object?> get props =>
      [id, subjectId, year, title, totalQuestions, durationMins, chapters];
}

class Chapter {
  final String id;
  final String name;

  Chapter({required this.id, required this.name});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(id: json['id'], name: json['name']);
  }
}

class ExamChapter extends Chapter {
  final int questionCount;

  ExamChapter({
    required super.id,
    required this.questionCount,
    required super.name,
  });

  @override
  factory ExamChapter.fromJson(Map<String, dynamic> json) {
    return ExamChapter(
        id: json['id'].toString(),
        questionCount: json['questionCount'] ?? 0,
        name: json['name']);
  }
}
