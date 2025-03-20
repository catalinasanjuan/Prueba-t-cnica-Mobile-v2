import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/blocs/auth/auth_bloc.dart';
import 'package:notes_app/screens/auth_screen.dart';
import 'package:notes_app/screens/notes_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isAuth = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == '/auth';

    if (!isAuth && !isAuthRoute) return '/auth';
    if (isAuth && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NotesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
      ),
    ),
  ],
);