import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class CacheItem extends HiveObject {
  @override
  @HiveField(0)
  String key;

  @HiveField(1)
  String data; // JSON string

  @HiveField(2)
  DateTime timestamp;

  CacheItem({
    required this.key,
    required this.data,
    required this.timestamp,
  });
}
