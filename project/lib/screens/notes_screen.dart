import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/blocs/auth/auth_bloc.dart';
import 'package:notes_app/blocs/notes/notes_bloc.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/widgets/error_handler.dart';
import 'package:notes_app/widgets/loading_overlay.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(NotesLoadRequested());
  }

  Future<void> _addNote() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const NoteDialog(),
    );

    if (result != null && mounted) {
      context.read<NotesBloc>().add(
            NoteCreateRequested(
              title: result['title']!,
              content: result['content']!,
            ),
          );
      ErrorHandler.showSuccess(context, 'Note created successfully');
    }
  }

  Future<void> _editNote(Note note) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => NoteDialog(
        initialTitle: note.title,
        initialContent: note.content,
        isEditing: true,
      ),
    );

    if (result != null && mounted) {
      context.read<NotesBloc>().add(
            NoteUpdateRequested(
              id: note.id,
              title: result['title']!,
              content: result['content']!,
            ),
          );
      ErrorHandler.showSuccess(context, 'Note updated successfully');
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<NotesBloc>().add(NoteDeleteRequested(id: note.id));
      ErrorHandler.showSuccess(context, 'Note deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesFailure) {
          ErrorHandler.showError(context, state.message);
        }
      },
      child: LoadingOverlay(
        isLoading: context.watch<NotesBloc>().state is NotesLoading,
        message: 'Loading notes...',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Notes')
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            ],
          ),
          body: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoaded) {
                return state.notes.isEmpty
                    ? Center(
                        child: Text(
                          'No notes yet. Create your first note!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ).animate().fadeIn(duration: 600.ms),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: state.notes.length,
                        itemBuilder: (context, index) {
                          final note = state.notes[index];
                          return NoteCard(
                            note: note,
                            onEdit: () => _editNote(note),
                            onDelete: () => _deleteNote(note),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: index * 100),
                                duration: 600.ms,
                              )
                              .slideX(begin: 0.3, end: 0);
                        },
                      );
              }

              return const SizedBox();
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNote,
            child: const Icon(Icons.add),
          )
              .animate()
              .scale(delay: 400.ms, duration: 600.ms)
              .fadeIn(delay: 400.ms, duration: 600.ms),
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(note.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.content),
            Text(
              DateFormat.yMMMd().format(note.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class NoteDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final bool isEditing;

  const NoteDialog({
    super.key,
    this.initialTitle,
    this.initialContent,
    this.isEditing = false,
  });

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Note' : 'Add New Note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'title': _titleController.text,
                'content': _contentController.text,
              });
            }
          },
          child: Text(widget.isEditing ? 'Update' : 'Add Note'),
        ),
      ],
    );
  }
}