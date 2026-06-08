import 'package:supabase_flutter/supabase_flutter.dart';

class WaterRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getTodayWater() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

    final response = await _supabase
        .from('water_logs')
        .select('amount_ml')
        .gte('logged_at', startOfDay)
        .eq('user_id', userId);

    if (response.isEmpty) return 0;

    int total = 0;
    for (final row in response) {
      total += (row['amount_ml'] as num).toInt();
    }
    return total;
  }

  Future<void> addWater(int amountMl) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase.from('water_logs').insert({
      'user_id': userId,
      'amount_ml': amountMl,
      'logged_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
