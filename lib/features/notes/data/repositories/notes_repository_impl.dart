import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NoteSubject>> getNotesByGrade(int grade) async {
    try {
      final noteSubjectModels = await localDataSource.getNotesByGrade(grade);
      return noteSubjectModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load notes for grade $grade: $e');
    }
  }

  @override
  Future<List<Note>> getNotesByChapter(String chapterId) async {
    try {
      final noteModels = await localDataSource.getNotesByChapter(chapterId);
      return noteModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load notes for chapter $chapterId: $e');
    }
  }

  @override
  Future<Note?> getNoteById(String noteId) async {
    try {
      final noteModel = await localDataSource.getNoteById(noteId);
      return noteModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to load note $noteId: $e');
    }
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    try {
      final noteModels = await localDataSource.searchNotes(query);
      return noteModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }

  @override
  Future<List<int>> getAvailableGrades() async {
    try {
      return await localDataSource.getAvailableGrades();
    } catch (e) {
      throw Exception('Failed to load available grades: $e');
    }
  }
}
