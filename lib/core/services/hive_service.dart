import 'package:exam_app/core/di/cache_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../constants/hive_constants.dart';
import '../../features/exams/data/models/exam_model.dart';
// import '../../features/exams/data/models/subject_model.dart';

@singleton
class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    // Hive.registerAdapter(ExamModelAdapter());
    // Hive.registerAdapter(SubjectModelAdapter());

    // Open Boxes
    await Hive.openBox<CacheItem>(HiveBoxNames.httpCache);
    await Hive.openBox<ExamModel>(HiveBoxNames.exams);
  }

  // Helper methods for box access
  Box<ExamModel> get examsBox => Hive.box<ExamModel>(HiveBoxNames.exams);

  Box<CacheItem> get cacheBox => Hive.box<CacheItem>(HiveBoxNames.httpCache);

  // Clean up method
  Future<void> closeBoxes() async {
    await Hive.close();
  }
}
