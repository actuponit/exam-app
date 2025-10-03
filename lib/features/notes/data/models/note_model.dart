import 'package:equatable/equatable.dart';
import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/note.dart';

part 'note_model.g.dart';

@HiveType(typeId: HiveTypeIds.notes)
class NoteModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final String subjectId;
  @HiveField(4)
  final String subjectName;
  @HiveField(5)
  final int grade;
  @HiveField(6)
  final String chapterId;
  @HiveField(7)
  final String chapterName;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final DateTime updatedAt;
  @HiveField(10)
  final List<String> tags;
  @HiveField(11)
  final String? imageUrl;
  @HiveField(12)
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
      id: json['id'].toString(),
      title: json['title'] as String,
      content: json['content'] as String,
      subjectId: json['subjectId'].toString(),
      subjectName: json['subjectName'] as String,
      grade: int.tryParse(json['grade'] ?? '0') ?? 0,
      chapterId: json['chapterId'].toString(),
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

@HiveType(typeId: HiveTypeIds.noteChapter)
class NoteChapterModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String subjectId;
  @HiveField(3)
  final int grade;
  @HiveField(4)
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
      id: json['id'].toString(),
      name: json['name'] as String,
      subjectId: json['subjectId'].toString(),
      grade: int.tryParse((json['grade'] ?? '0')) ?? 0,
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

@HiveType(typeId: HiveTypeIds.noteSubject)
class NoteSubjectModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int grade;
  @HiveField(3)
  final String iconName;
  @HiveField(4)
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
      id: json['id'].toString(),
      name: json['name'] as String,
      grade: int.tryParse((json['grade'] ?? '0')) ?? 0,
      iconName: json['iconName'] as String? ?? 'book',
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

@HiveType(typeId: HiveTypeIds.notesList)
class NotesListModel extends Equatable {
  @HiveField(0)
  final List<NoteSubjectModel> subjects;

  const NotesListModel({
    required this.subjects,
  });

  @override
  List<Object?> get props => [subjects];
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
