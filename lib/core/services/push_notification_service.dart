import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  static final _supabase = Supabase.instance.client;

  /// Wywołaj po zalogowaniu usera
  static Future<void> registerToken(String expoPushToken) async {
    try {
      await _supabase.functions.invoke('manage-push-token', body: {
        'action': 'register',
        'token': expoPushToken,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('PushNotificationService.registerToken error: $e');
    }
  }

  static Future<void> unregisterToken(String expoPushToken) async {
    try {
      await _supabase.functions.invoke('manage-push-token', body: {
        'action': 'unregister',
        'token': expoPushToken,
      });
    } catch (e) {
      debugPrint('PushNotificationService.unregisterToken error: $e');
    }
  }
}
