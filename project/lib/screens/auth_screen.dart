import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:notes_app/blocs/auth/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final event = _isRegistering
        ? AuthRegisterRequested(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          );

    context.read<AuthBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegistering ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: 0.3, end: 0),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: state is AuthLoading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(_isRegistering ? 'Register' : 'Login'),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 600.ms);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                      });
                    },
                    child: Text(
                      _isRegistering
                          ? 'Already have an account? Login'
                          : "Don't have an account? Register",
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}