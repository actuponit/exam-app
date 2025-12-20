import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final String subjectId;
  final String subjectName;
  final int grade;
  final String chapterId;
  final String chapterName;
  final String? language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.subjectId,
    required this.subjectName,
    required this.grade,
    required this.chapterId,
    required this.chapterName,
    required this.createdAt,
    required this.updatedAt,
    this.language,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? subjectId,
    String? subjectName,
    int? grade,
    String? chapterId,
    String? chapterName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      grade: grade ?? this.grade,
      chapterId: chapterId ?? this.chapterId,
      chapterName: chapterName ?? this.chapterName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        subjectId,
        subjectName,
        grade,
        chapterId,
        chapterName,
        createdAt,
        updatedAt,
      ];
}

class NoteChapter extends Equatable {
  final String id;
  final String name;
  final String subjectId;
  final int grade;
  final List<Note> notes;

  const NoteChapter({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.grade,
    this.notes = const [],
  });

  NoteChapter copyWith({
    String? id,
    String? name,
    String? subjectId,
    int? grade,
    List<Note>? notes,
  }) {
    return NoteChapter(
      id: id ?? this.id,
      name: name ?? this.name,
      subjectId: subjectId ?? this.subjectId,
      grade: grade ?? this.grade,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, name, subjectId, grade, notes];
}

class NoteSubject extends Equatable {
  final String id;
  final String name;
  final int grade;
  final String iconName;
  final List<NoteChapter> chapters;

  const NoteSubject({
    required this.id,
    required this.name,
    required this.grade,
    required this.iconName,
    this.chapters = const [],
  });

  NoteSubject copyWith({
    String? id,
    String? name,
    int? grade,
    String? iconName,
    List<NoteChapter>? chapters,
  }) {
    return NoteSubject(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      iconName: iconName ?? this.iconName,
      chapters: chapters ?? this.chapters,
    );
  }

  @override
  List<Object?> get props => [id, name, grade, iconName, chapters];
}
