import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

class NoteModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String subjectId;
  final String subjectName;
  final int grade;
  final String chapterId;
  final String chapterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? imageUrl;
  final bool isLocked;

  const NoteModel({
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
    this.tags = const [],
    this.imageUrl,
    this.isLocked = false,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      grade: json['grade'] as int,
      chapterId: json['chapterId'] as String,
      chapterName: json['chapterName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'grade': grade,
      'chapterId': chapterId,
      'chapterName': chapterName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'imageUrl': imageUrl,
      'isLocked': isLocked,
    };
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
        tags,
        imageUrl,
        isLocked,
      ];
}

class NoteChapterModel extends Equatable {
  final String id;
  final String name;
  final String subjectId;
  final int grade;
  final List<NoteModel> notes;

  const NoteChapterModel({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.grade,
    this.notes = const [],
  });

  factory NoteChapterModel.fromJson(Map<String, dynamic> json) {
    return NoteChapterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      subjectId: json['subjectId'] as String,
      grade: json['grade'] as int,
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjectId': subjectId,
      'grade': grade,
      'notes': notes.map((note) => note.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, subjectId, grade, notes];
}

class NoteSubjectModel extends Equatable {
  final String id;
  final String name;
  final int grade;
  final String iconName;
  final List<NoteChapterModel> chapters;

  const NoteSubjectModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.iconName,
    this.chapters = const [],
  });

  factory NoteSubjectModel.fromJson(Map<String, dynamic> json) {
    return NoteSubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      grade: json['grade'] as int,
      iconName: json['iconName'] as String,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => NoteChapterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'iconName': iconName,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, grade, iconName, chapters];
}

// Extension methods to convert models to entities
extension NoteModelExtension on NoteModel {
  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      subjectId: subjectId,
      subjectName: subjectName,
      grade: grade,
      chapterId: chapterId,
      chapterName: chapterName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension NoteChapterModelExtension on NoteChapterModel {
  NoteChapter toEntity() {
    return NoteChapter(
      id: id,
      name: name,
      subjectId: subjectId,
      grade: grade,
      notes: notes.map((note) => note.toEntity()).toList(),
    );
  }
}

extension NoteSubjectModelExtension on NoteSubjectModel {
  NoteSubject toEntity() {
    return NoteSubject(
      id: id,
      name: name,
      grade: grade,
      iconName: iconName,
      chapters: chapters.map((chapter) => chapter.toEntity()).toList(),
    );
  }
}
