// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 2;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionModel(
      id: fields[0] as String,
      text: fields[1] as String,
      options: (fields[2] as List).cast<OptionModel>(),
      correctOption: fields[3] as String,
      explanation: fields[4] as String?,
      year: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      isAttempted: fields[7] as bool,
      chapter: fields[8] as ExamChapterModel,
      subject: fields[9] as SubjectModel,
      region: fields[10] as String?,
      image: fields[11] as String?,
      imagePath: fields[12] as String?,
      explanationImagePath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.options)
      ..writeByte(3)
      ..write(obj.correctOption)
      ..writeByte(4)
      ..write(obj.explanation)
      ..writeByte(5)
      ..write(obj.year)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isAttempted)
      ..writeByte(8)
      ..write(obj.chapter)
      ..writeByte(9)
      ..write(obj.subject)
      ..writeByte(10)
      ..write(obj.region)
      ..writeByte(11)
      ..write(obj.image)
      ..writeByte(12)
      ..write(obj.imagePath)
      ..writeByte(13)
      ..write(obj.explanationImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OptionModelAdapter extends TypeAdapter<OptionModel> {
  @override
  final int typeId = 3;

  @override
  OptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OptionModel(
      id: fields[0] as String,
      text: fields[1] as String,
      image: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OptionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(12)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
