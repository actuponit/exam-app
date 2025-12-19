import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:hive/hive.dart';

part 'cache_item.g.dart'; // REQUIRED

@HiveType(typeId: HiveTypeIds.cache)
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
