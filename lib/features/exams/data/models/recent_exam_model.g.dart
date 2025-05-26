// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_exam_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentExamModelAdapter extends TypeAdapter<RecentExamModel> {
  @override
  final int typeId = 6;

  @override
  RecentExamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentExamModel(
      subject: fields[0] as SubjectModel,
      year: fields[1] as int,
      chapter: fields[2] as ExamChapterModel?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentExamModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.chapter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentExamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
