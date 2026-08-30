// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 11;

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      locked: fields[3] == null ? false : fields[3] as bool,
      downloadUrl: fields[4] == null ? '' : fields[4] as String,
      fileSizeBytes: fields[5] == null ? 0 : fields[5] as int,
      checksum: fields[6] as String?,
      durationSeconds: fields[7] as int?,
      thumbnailUrl: fields[8] as String?,
      mimeType: fields[9] as String?,
      grade: fields[10] as int?,
      language: fields[11] as String?,
      sortOrder: fields[12] == null ? 0 : fields[12] as int,
      isActive: fields[13] == null ? true : fields[13] as bool,
      subjectId: fields[14] == null ? '' : fields[14] as String,
      chapterId: fields[15] as String?,
      chapterName: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.locked)
      ..writeByte(4)
      ..write(obj.downloadUrl)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.checksum)
      ..writeByte(7)
      ..write(obj.durationSeconds)
      ..writeByte(8)
      ..write(obj.thumbnailUrl)
      ..writeByte(9)
      ..write(obj.mimeType)
      ..writeByte(10)
      ..write(obj.grade)
      ..writeByte(11)
      ..write(obj.language)
      ..writeByte(12)
      ..write(obj.sortOrder)
      ..writeByte(13)
      ..write(obj.isActive)
      ..writeByte(14)
      ..write(obj.subjectId)
      ..writeByte(15)
      ..write(obj.chapterId)
      ..writeByte(16)
      ..write(obj.chapterName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
