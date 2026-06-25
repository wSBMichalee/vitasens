import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/core/services/cache_service.dart';

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
    print('SignUp response: ${response.data}');
    print('SignUp status: ${response.status}');
    final responseData = response.data as Map;
    return Map<String, dynamic>.from(responseData['data'] as Map);
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
  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(
      clientId: '965374839295-0f812oks249d17kn70o2riiej0fntkek.apps.googleusercontent.com',
    ).signIn();
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
  }

  // ─── Sign In with Apple ───────────────────────────────────────────────────────
  Future<void> signInWithApple() async {
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
  }

  // ─── Get User Profile ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getUserProfile() async {
    return CacheService().fetchWithStaleWhileRevalidate(
      key: 'user_profile',
      fetchFuture: () async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) throw Exception('Not authenticated');
        final response = await _client
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .single();
        return {
          'id': response['id'],
          'email': _client.auth.currentUser?.email ?? '',
          'full_name': response['name'],
          'onboarding_completed': response['onboarding_completed'],
          'subscription_status': response['subscription_status'],
          'trial_expires_at': response['trial_expires_at'],
          'goal_type': response['goal_type'],
          'daily_calorie_target': response['daily_calorie_target'],
          'daily_protein_target': response['daily_protein_target'],
          'daily_carbs_target': response['daily_carbs_target'],
          'daily_fat_target': response['daily_fat_target'],
          'goal_pace': response['goal_pace'],
          'activity_level': response['activity_level'],
          'weight_kg': response['weight_kg'],
          'target_weight_kg': response['target_weight_kg'],
          'height_cm': response['height_cm'],
          'gender': response['gender'],
          'age': response['age'],
          'daily_water_target': response['daily_water_target'],
          'avatar_url': response['avatar_url'],
          'allergies': response['allergies'],
          'health_conditions': response['health_conditions'],
          'dietary_preferences': response['dietary_preferences'],
        };
      },
    );
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
    CacheService().invalidate('user_profile');
  }

  // ─── Calculate Targets ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> calculateTargets() async {
    return CacheService().fetchWithStaleWhileRevalidate(
      key: 'user_targets',
      fetchFuture: () async {
        final response = await _client.functions.invoke(
          'manage-profile',
          body: {
            'action': 'calculate_targets',
          },
        );
        final responseData = response.data as Map;
        return Map<String, dynamic>.from(responseData['data'] as Map);
      },
    );
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
