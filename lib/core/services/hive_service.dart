import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:exam_app/core/di/cache_item.dart';
import 'package:exam_app/features/exams/data/models/exam_model.dart';
import 'package:hive/hive.dart';

class HiveService {
  Future<void> init() async {
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
