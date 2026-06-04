import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';

class PantryRepository {
  final SupabaseClient _supabase;

  PantryRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<IngredientModel>> getIngredients() async {
    final response = await _supabase.functions.invoke(
      'manage-pantry',
      body: {'action': 'list'},
    );

    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => IngredientModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<IngredientModel>> getExpiring({int days = 3}) async {
    final response = await _supabase.functions.invoke(
      'manage-pantry',
      body: {'action': 'expiring', 'days': days},
    );

    final payload = response.data['data'] as Map<String, dynamic>?;
    if (payload == null) return [];
    final List<dynamic> data = payload['expiringSoonItems'] ?? [];
    return data.map((json) => IngredientModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> deleteIngredient(String id) async {
    await _supabase.functions.invoke(
      'manage-pantry',
      body: {'action': 'delete', 'id': id},
    );
  }

  Future<void> addIngredient({
    required String pantryId,
    required String name,
    required double quantity,
    required String unit,
    String? category,
    DateTime? expiryDate,
  }) async {
    await _supabase.functions.invoke(
      'manage-pantry',
      body: {
        'action': 'add',
        'pantry_id': pantryId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
      },
    );
  }
}
