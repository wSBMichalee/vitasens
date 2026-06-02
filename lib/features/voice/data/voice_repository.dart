import 'package:vitasense/core/supabase/supabase_client.dart';

class VoiceRepository {
  final SupabaseClientService _supabaseService;

  VoiceRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<Map<String, dynamic>> parseSpeech(String text) async {
    final response = await _supabaseService.invokeFunction(
      'voice-log-meal',
      body: {
        'action': 'parse_speech',
        'speechText': text,
      },
    );

    return response as Map<String, dynamic>;
  }

  Future<void> logMeal(Map<String, dynamic> mealData) async {
    await _supabaseService.invokeFunction(
      'voice-log-meal',
      body: {
        'action': 'log',
        ...mealData,
      },
    );
  }
}
