import 'package:exam_app/core/constants/hive_constants.dart';
import 'package:exam_app/core/di/cache_item.dart';
import 'package:exam_app/features/exams/data/models/exam_model.dart';
import 'package:exam_app/features/exams/data/models/subject_model.dart';
import 'package:exam_app/features/exams/data/models/recent_exam_model.dart';
import 'package:exam_app/features/notes/data/models/note_model.dart';
import 'package:exam_app/features/quiz/data/models/question_model.dart';
import 'package:hive/hive.dart';

class HiveService {
  Future<void> init() async {
    // Register Adapters
    Hive.registerAdapter(QuestionModelAdapter());
    Hive.registerAdapter(OptionModelAdapter());
    Hive.registerAdapter(ExamModelAdapter());
    Hive.registerAdapter(ExamChapterModelAdapter());
    Hive.registerAdapter(SubjectModelAdapter());
    Hive.registerAdapter(RecentExamModelAdapter());
    Hive.registerAdapter(NoteSubjectModelAdapter());
    Hive.registerAdapter(NoteChapterModelAdapter());
    Hive.registerAdapter(NotesListModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());

    // Open Boxes
    await Hive.openBox<CacheItem>(HiveBoxNames.httpCache);
    await Hive.openBox<ExamModel>(HiveBoxNames.exams);
    await Hive.openBox<SubjectModel>(HiveBoxNames.subjects);
    await Hive.openBox<QuestionModel>(HiveBoxNames.questions);
    await Hive.openBox<RecentExamModel>(HiveBoxNames.recentExams);
    await Hive.openBox<NotesListModel>(HiveBoxNames.notes);
  }

  // Helper methods for box accessw
  Box<ExamModel> get examsBox => Hive.box<ExamModel>(HiveBoxNames.exams);
  Box<SubjectModel> get subjectsBox =>
      Hive.box<SubjectModel>(HiveBoxNames.subjects);
  Box<QuestionModel> get questionsBox =>
      Hive.box<QuestionModel>(HiveBoxNames.questions);
  Box<CacheItem> get cacheBox => Hive.box<CacheItem>(HiveBoxNames.httpCache);
  Box<RecentExamModel> get recentExamsBox =>
      Hive.box<RecentExamModel>(HiveBoxNames.recentExams);
  Box<NotesListModel> get notesBox =>
      Hive.box<NotesListModel>(HiveBoxNames.notes);
  // Clean up method
  Future<void> closeBoxes() async {
    await Hive.close();
  }
}
