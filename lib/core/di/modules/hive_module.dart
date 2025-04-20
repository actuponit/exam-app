import 'package:injectable/injectable.dart';
import 'package:exam_app/core/services/hive_service.dart';

@module
abstract class HiveModule {
  @singleton
  @preResolve
  Future<HiveService> get hiveService async {
    final service = HiveService();
    await service.init();
    return service;
  }
} 