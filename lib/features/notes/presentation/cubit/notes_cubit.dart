import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository repository;

  NotesCubit({required this.repository}) : super(const NotesInitial());

  Future<void> loadNotes(String subject) async {
    emit(const NotesLoading());

    try {
      repository.loadNotes(subject);
      final availableGrades = await repository.getAvailableGrades();
      final selectedGrade = availableGrades.firstOrNull ?? 0;
      final subjects = await repository.getNotesByGrade(selectedGrade);

      emit(NotesLoaded(
        subjects: subjects,
        availableGrades: availableGrades,
        selectedGrade: selectedGrade,
      ));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> changeGrade(int grade) async {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(const NotesLoading());

      try {
        final subjects = await repository.getNotesByGrade(grade);
        emit(currentState.copyWith(
          subjects: subjects,
          selectedGrade: grade,
        ));
      } catch (e) {
        emit(NotesError(message: e.toString()));
      }
    }
  }

  Future<void> loadNoteDetail(String noteId) async {
    emit(const NoteDetailLoading());

    try {
      final note = await repository.getNoteById(noteId);
      if (note != null) {
        emit(NoteDetailLoaded(note: note));
      } else {
        emit(const NoteDetailError(message: 'Note not found'));
      }
    } catch (e) {
      emit(NoteDetailError(message: e.toString()));
    }
  }

  Future<void> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      // Return to normal notes view
      await loadNotes("");
      return;
    }

    emit(const NotesSearchLoading());

    try {
      final searchResults = await repository.searchNotes(query.trim());
      emit(NotesSearchLoaded(
        searchResults: searchResults,
        query: query.trim(),
      ));
    } catch (e) {
      emit(NotesSearchError(message: e.toString()));
    }
  }

  void clearSearch() {
    loadNotes("");
  }
}
