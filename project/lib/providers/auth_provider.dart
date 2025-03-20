import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((event) {
      _user = event.session?.user;
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}