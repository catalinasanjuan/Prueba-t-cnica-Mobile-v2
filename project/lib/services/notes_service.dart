import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notes_app/models/note.dart';

class NotesService {
  final _supabase = Supabase.instance.client;

  Future<List<Note>> getNotes() async {
    final response = await _supabase
        .from('notes')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((note) => Note.fromJson(note)).toList();
  }

  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final response = await _supabase.from('notes').insert({
      'title': title,
      'content': content,
      'user_id': _supabase.auth.currentUser!.id,
    }).select().single();
    
    return Note.fromJson(response);
  }

  Future<void> deleteNote(String id) async {
    await _supabase.from('notes').delete().match({'id': id});
  }

  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final response = await _supabase
        .from('notes')
        .update({
          'title': title,
          'content': content,
        })
        .match({'id': id})
        .select()
        .single();
    
    return Note.fromJson(response);
  }
}