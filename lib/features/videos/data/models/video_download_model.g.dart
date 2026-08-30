// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_download_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoDownloadModelAdapter extends TypeAdapter<VideoDownloadModel> {
  @override
  final int typeId = 12;

  @override
  VideoDownloadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoDownloadModel(
      videoId: fields[0] as String,
      localPath: fields[1] as String,
      verified: fields[2] == null ? false : fields[2] as bool,
      resumePositionSeconds: fields[3] == null ? 0 : fields[3] as int,
      video: fields[4] as VideoModel?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoDownloadModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.localPath)
      ..writeByte(2)
      ..write(obj.verified)
      ..writeByte(3)
      ..write(obj.resumePositionSeconds)
      ..writeByte(4)
      ..write(obj.video);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoDownloadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
