// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheItemAdapter extends TypeAdapter<CacheItem> {
  @override
  final int typeId = 5;

  @override
  CacheItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheItem(
      key: fields[0] as String,
      data: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CacheItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
