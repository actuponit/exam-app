// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamModelAdapter extends TypeAdapter<ExamModel> {
  @override
  final int typeId = 0;

  @override
  ExamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamModel(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      year: fields[2] as int,
      title: fields[3] as String,
      totalQuestions: fields[4] as int,
      durationMins: fields[5] as int,
      chapters: (fields[6] as List).cast<ExamChapterModel>(),
      region: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExamModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.totalQuestions)
      ..writeByte(5)
      ..write(obj.durationMins)
      ..writeByte(6)
      ..write(obj.chapters)
      ..writeByte(7)
      ..write(obj.region);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamChapterModelAdapter extends TypeAdapter<ExamChapterModel> {
  @override
  final int typeId = 4;

  @override
  ExamChapterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamChapterModel(
      id: fields[0] as String,
      name: fields[1] as String,
      questionCount: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExamChapterModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.questionCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamChapterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
