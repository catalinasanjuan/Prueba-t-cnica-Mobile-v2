import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/notes_service.dart';

// Events
abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesLoadRequested extends NotesEvent {}

class NoteCreateRequested extends NotesEvent {
  final String title;
  final String content;

  NoteCreateRequested({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class NoteUpdateRequested extends NotesEvent {
  final String id;
  final String title;
  final String content;

  NoteUpdateRequested({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class NoteDeleteRequested extends NotesEvent {
  final String id;

  NoteDeleteRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

// States
abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;

  NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NotesFailure extends NotesState {
  final String message;

  NotesFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService;

  NotesBloc(this._notesService) : super(NotesInitial()) {
    on<NotesLoadRequested>(_onNotesLoadRequested);
    on<NoteCreateRequested>(_onNoteCreateRequested);
    on<NoteUpdateRequested>(_onNoteUpdateRequested);
    on<NoteDeleteRequested>(_onNoteDeleteRequested);
  }

  Future<void> _onNotesLoadRequested(
    NotesLoadRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final notes = await _notesService.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesFailure(e.toString()));
    }
  }

  Future<void> _onNoteCreateRequested(
    NoteCreateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesService.createNote(
        title: event.title,
        content: event.content,
      );
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesFailure(e.toString()));
    }
  }

  Future<void> _onNoteUpdateRequested(
    NoteUpdateRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesService.updateNote(
        id: event.id,
        title: event.title,
        content: event.content,
      );
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesFailure(e.toString()));
    }
  }

  Future<void> _onNoteDeleteRequested(
    NoteDeleteRequested event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _notesService.deleteNote(event.id);
      add(NotesLoadRequested());
    } catch (e) {
      emit(NotesFailure(e.toString()));
    }
  }
}