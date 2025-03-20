import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/blocs/auth/auth_bloc.dart';
import 'package:notes_app/blocs/notes/notes_bloc.dart';
import 'package:notes_app/services/notes_service.dart';
import 'package:notes_app/router.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => NotesBloc(NotesService())),
      ],
      child: MaterialApp.router(
        title: 'Notes App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}