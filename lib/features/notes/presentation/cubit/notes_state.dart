part of 'notes_cubit.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  final List<NoteSubject> subjects;
  final List<int> availableGrades;
  final int selectedGrade;

  const NotesLoaded({
    required this.subjects,
    required this.availableGrades,
    required this.selectedGrade,
  });

  NotesLoaded copyWith({
    List<NoteSubject>? subjects,
    List<int>? availableGrades,
    int? selectedGrade,
  }) {
    return NotesLoaded(
      subjects: subjects ?? this.subjects,
      availableGrades: availableGrades ?? this.availableGrades,
      selectedGrade: selectedGrade ?? this.selectedGrade,
    );
  }

  @override
  List<Object?> get props => [subjects, availableGrades, selectedGrade];
}

class NotesError extends NotesState {
  final String message;

  const NotesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NoteDetailLoading extends NotesState {
  const NoteDetailLoading();
}

class NoteDetailLoaded extends NotesState {
  final Note note;

  const NoteDetailLoaded({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteDetailError extends NotesState {
  final String message;

  const NoteDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotesSearchLoading extends NotesState {
  const NotesSearchLoading();
}

class NotesSearchLoaded extends NotesState {
  final List<Note> searchResults;
  final String query;

  const NotesSearchLoaded({
    required this.searchResults,
    required this.query,
  });

  @override
  List<Object?> get props => [searchResults, query];
}

class NotesSearchError extends NotesState {
  final String message;

  const NotesSearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
