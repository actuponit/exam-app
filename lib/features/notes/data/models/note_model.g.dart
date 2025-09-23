// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 9;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      subjectId: fields[3] as String,
      subjectName: fields[4] as String,
      grade: fields[5] as int,
      chapterId: fields[6] as String,
      chapterName: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      tags: (fields[10] as List).cast<String>(),
      imageUrl: fields[11] as String?,
      isLocked: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.subjectName)
      ..writeByte(5)
      ..write(obj.grade)
      ..writeByte(6)
      ..write(obj.chapterId)
      ..writeByte(7)
      ..write(obj.chapterName)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.imageUrl)
      ..writeByte(12)
      ..write(obj.isLocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteChapterModelAdapter extends TypeAdapter<NoteChapterModel> {
  @override
  final int typeId = 8;

  @override
  NoteChapterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteChapterModel(
      id: fields[0] as String,
      name: fields[1] as String,
      subjectId: fields[2] as String,
      grade: fields[3] as int,
      notes: (fields[4] as List).cast<NoteModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteChapterModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteChapterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteSubjectModelAdapter extends TypeAdapter<NoteSubjectModel> {
  @override
  final int typeId = 7;

  @override
  NoteSubjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteSubjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      grade: fields[2] as int,
      iconName: fields[3] as String,
      chapters: (fields[4] as List).cast<NoteChapterModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteSubjectModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.grade)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteSubjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotesListModelAdapter extends TypeAdapter<NotesListModel> {
  @override
  final int typeId = 10;

  @override
  NotesListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotesListModel(
      subjects: (fields[0] as List).cast<NoteSubjectModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotesListModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.subjects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
