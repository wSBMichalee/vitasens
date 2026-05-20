import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── KONFIGURACJA SUPABASE ─────────────────────────────────────────────────────
class SupabaseConfig {
  const SupabaseConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}

// ─── SINGLETON KLIENT SUPABASE ──────────────────────────────────────────────────
class SupabaseClientService {
  SupabaseClientService._();

  static final SupabaseClientService instance = SupabaseClientService._();

  // Dostęp do SupabaseClient
  SupabaseClient get client => Supabase.instance.client;

  // Inicjalizacja (wywoływana jednorazowo w main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  // ─── AUTH HELPERS ────────────────────────────────────────────────────────────

  /// Aktualnie zalogowany użytkownik (null jeśli niezalogowany)
  User? get currentUser => client.auth.currentUser;

  /// Strumień zmian stanu autoryzacji
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Czy użytkownik jest zalogowany
  bool get isAuthenticated => currentUser != null;

  /// ID zalogowanego użytkownika (null jeśli niezalogowany)
  String? get userId => currentUser?.id;

  // ─── EDGE FUNCTIONS ───────────────────────────────────────────────────────────

  /// Wywołuje Supabase Edge Function (Deno) z opcjonalnym body JSON
  Future<dynamic> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    final response = await client.functions.invoke(
      functionName,
      body: body,
    );

    if (response.status != 200) {
      throw Exception(
        'Edge Function error [$functionName]: ${response.data}',
      );
    }

    return response.data;
  }

  // ─── AUTH ACTIONS ─────────────────────────────────────────────────────────────

  /// Wylogowanie użytkownika
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}

// ─── EXTENSION NA BUILD CONTEXT ──────────────────────────────────────────────────
extension SupabaseContext on BuildContext {
  /// Szybki dostęp do SupabaseClient z poziomu widgetów
  SupabaseClient get supabase => SupabaseClientService.instance.client;
}
