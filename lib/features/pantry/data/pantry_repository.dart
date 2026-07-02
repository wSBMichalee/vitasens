import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'package:vitasense/core/services/cache_service.dart';

class PantryRepository {
  final SupabaseClient _supabase;

  PantryRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<String?> _getPantryId() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final existing = await _supabase
        .from('pantries')
        .select('id')
        .eq('owner_id', userId)
        .maybeSingle();
    if (existing != null) return existing['id'] as String;
    final created = await _supabase
        .from('pantries')
        .insert({'owner_id': userId})
        .select('id')
        .single();
    return created['id'] as String;
  }

  Future<List<IngredientModel>> getIngredients() async {
    return CacheService().fetchWithStaleWhileRevalidate(
      key: 'pantry_ingredients',
      fetchFuture: () async {
        final pantryId = await _getPantryId();
        if (pantryId == null) return [];
        final data = await _supabase
            .from('ingredients')
            .select('*')
            .eq('pantry_id', pantryId)
            .order('created_at', ascending: false);
        return (data as List)
            .map((json) => IngredientModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<IngredientModel>> getExpiring({int days = 3}) async {
    final pantryId = await _getPantryId();
    if (pantryId == null) return [];
    final cutoff = DateTime.now().add(Duration(days: days)).toIso8601String();
    final data = await _supabase
        .from('ingredients')
        .select('*')
        .eq('pantry_id', pantryId)
        .lte('expiry_date', cutoff)
        .gte('expiry_date', DateTime.now().toIso8601String())
        .order('expiry_date');
    return (data as List)
        .map((json) => IngredientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addIngredient({
    required String pantryId,
    required String name,
    required double quantity,
    required String unit,
    String? category,
    DateTime? expiryDate,
    String? imageUrl,
    String storageLocation = 'fridge',
  }) async {
    final resolvedPantryId = await _getPantryId();
    if (resolvedPantryId == null) throw Exception('Not authenticated');
    await _supabase.from('ingredients').insert({
      'pantry_id': resolvedPantryId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category ?? 'other',
      if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      'storage_location': storageLocation,
    });
    CacheService().invalidate('pantry_ingredients');
    CacheService().invalidatePattern('recipes_');
  }

  Future<void> deleteIngredient(String id) async {
    await _supabase.from('ingredients').delete().eq('id', id);
    CacheService().invalidate('pantry_ingredients');
    CacheService().invalidatePattern('recipes_');
  }

  Future<void> moveIngredient(String id, String storageLocation) async {
    await _supabase
        .from('ingredients')
        .update({'storage_location': storageLocation})
        .eq('id', id);
    CacheService().invalidate('pantry_ingredients');
    CacheService().invalidatePattern('recipes_');
  }
}
