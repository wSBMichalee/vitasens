import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/core/services/cache_service.dart';

class MacrosRepository {
  final SupabaseClient _supabase;

  MacrosRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> getDailyMacros(String date) async {
    return CacheService().fetchWithStaleWhileRevalidate(
      key: 'daily_macros_$date',
      fetchFuture: () async {
        final response = await _supabase.functions.invoke(
          'calculate-daily-macros',
          body: {
            'action': 'daily',
            'date': date,
          },
        );
        final body = response.data as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      },
    );
  }

  Future<Map<String, dynamic>> getWeeklyMacros(
      String startDate, String endDate) async {
    return CacheService().fetchWithStaleWhileRevalidate(
      key: 'weekly_macros_${startDate}_$endDate',
      fetchFuture: () async {
        final response = await _supabase.functions.invoke(
          'calculate-daily-macros',
          body: {
            'action': 'weekly',
            'startDate': startDate,
            'endDate': endDate,
          },
        );
        final body = response.data as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMealsForDate(String date) async {
    final response = await _supabase.functions.invoke(
      'calculate-daily-macros',
      body: {
        'action': 'meals',
        'date': date,
      },
    );

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
