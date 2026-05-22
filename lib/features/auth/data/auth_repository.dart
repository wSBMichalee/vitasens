import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Sign Up ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.functions.invoke(
      'manage-auth',
      body: {
        'action': 'sign_up',
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── Sign In ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;
    if (session == null) {
      throw Exception('Sign in failed: no session returned');
    }

    return {
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'user_id': session.user.id,
    };
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Reset Password ───────────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _client.functions.invoke(
      'manage-auth',
      body: {
        'action': 'reset_password',
        'email': email,
      },
    );
  }

  // ─── Sign In with Google ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final googleIdToken = googleAuth.idToken;
    if (googleIdToken == null) {
      throw Exception('Failed to retrieve Google ID token');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleIdToken,
    );

    final response = await _client.functions.invoke(
      'manage-auth',
      body: {
        'action': 'oauth_callback',
        'provider': 'google',
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── Sign In with Apple ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final appleIdToken = credential.identityToken;
    if (appleIdToken == null) {
      throw Exception('Failed to retrieve Apple identity token');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: appleIdToken,
    );

    final response = await _client.functions.invoke(
      'manage-auth',
      body: {
        'action': 'oauth_callback',
        'provider': 'apple',
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── Get User Profile ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _client.functions.invoke(
      'manage-auth',
      body: {
        'action': 'get_user',
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── Update Profile ───────────────────────────────────────────────────────────
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.functions.invoke(
      'manage-profile',
      body: {
        'action': 'update_profile',
        ...data,
      },
    );
  }

  // ─── Calculate Targets ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> calculateTargets() async {
    final response = await _client.functions.invoke(
      'manage-profile',
      body: {
        'action': 'calculate_targets',
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  // ─── Complete Onboarding ──────────────────────────────────────────────────────
  Future<void> completeOnboarding() async {
    await _client.functions.invoke(
      'manage-profile',
      body: {
        'action': 'complete_onboarding',
      },
    );
  }
}
