import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<NoteSubject>> getNotesByGrade(int grade);
  Future<List<Note>> getNotesByChapter(String chapterId);
  Future<Note?> getNoteById(String noteId);
  Future<List<Note>> searchNotes(String query);
  Future<List<int>> getAvailableGrades();
  Future<void> loadNotes(String name);
}
