import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  // ─── App Started ──────────────────────────────────────────────────────────────
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        final profileData = await _authRepository.getUserProfile();
        final user = UserModel.fromJson(profileData);
        emit(AuthAuthenticated(user: user));
      } catch (_) {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────────────────────
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      final profileData = await _authRepository.getUserProfile();
      final user = UserModel.fromJson(profileData);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────────
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final data = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      final user = UserModel.fromJson(data);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Sign In with Google ──────────────────────────────────────────────────────
  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      final profileData = await _authRepository.getUserProfile();
      final user = UserModel.fromJson(profileData);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Sign In with Apple ───────────────────────────────────────────────────────
  Future<void> _onSignInWithAppleRequested(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithApple();
      final profileData = await _authRepository.getUserProfile();
      final user = UserModel.fromJson(profileData);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  // ─── Reset Password ───────────────────────────────────────────────────────────
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.resetPassword(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Error Parser ─────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    final raw = e.toString().toLowerCase();

    if (raw.contains('already been registered') ||
        raw.contains('already registered') ||
        raw.contains('email already')) {
      return 'This email is already registered. Sign in instead.';
    }
    if (raw.contains('invalid email') || raw.contains('invalid_email')) {
      return 'Please enter a valid email address.';
    }
    if (raw.contains('wrong password') ||
        raw.contains('invalid password') ||
        raw.contains('invalid_credentials')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('password') && raw.contains('characters')) {
      return 'Password must be at least 8 characters.';
    }
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No internet connection. Please try again.';
    }
    if (raw.contains('too many') || raw.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    if (raw.contains('not found') || raw.contains('user not found')) {
      return 'Account not found. Please sign up first.';
    }
    if (raw.contains('expired') || raw.contains('token expired')) {
      return 'Session expired. Please sign in again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
