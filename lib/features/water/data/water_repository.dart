import 'package:supabase_flutter/supabase_flutter.dart';

class WaterRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getWaterForDate(DateTime date) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final startOfDay = DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc().toIso8601String();

    final response = await _supabase
        .from('water_logs')
        .select('amount_ml')
        .gte('logged_at', startOfDay)
        .lte('logged_at', endOfDay)
        .eq('user_id', userId);

    if (response.isEmpty) return 0;

    int total = 0;
    for (final row in response) {
      total += (row['amount_ml'] as num).toInt();
    }
    return total;
  }

  Future<void> addWater(int amountMl, {DateTime? date}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final logDate = date ?? DateTime.now();

    await _supabase.from('water_logs').insert({
      'user_id': userId,
      'amount_ml': amountMl,
      'logged_at': logDate.toUtc().toIso8601String(),
    });
  }
}
