import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyAppCacheManager extends CacheManager {
  static const key = 'myAppCache';

  MyAppCacheManager._()
      : super(
          Config(
            key,
            stalePeriod:
                const Duration(days: 365 * 10), // effectively permanent
            maxNrOfCacheObjects: 1000,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );

  static final MyAppCacheManager _instance = MyAppCacheManager._();

  factory MyAppCacheManager() => _instance;
}
