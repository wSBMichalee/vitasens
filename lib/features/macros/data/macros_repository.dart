import 'package:supabase_flutter/supabase_flutter.dart';

class MacrosRepository {
  final SupabaseClient _supabase;

  MacrosRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> getDailyMacros(String date) async {
    final response = await _supabase.functions.invoke(
      'calculate-daily-macros',
      body: {
        'action': 'daily',
        'date': date,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWeeklyMacros(
      String startDate, String endDate) async {
    final response = await _supabase.functions.invoke(
      'calculate-daily-macros',
      body: {
        'action': 'weekly',
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase.functions.invoke(
      'calculate-daily-macros',
      body: {
        'action': 'meals',
        'date': today,
      },
    );

    final data = response.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
