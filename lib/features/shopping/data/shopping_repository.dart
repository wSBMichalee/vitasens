import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/features/shopping/data/models/shopping_item_model.dart';

class ShoppingRepository {
  final SupabaseClientService _supabaseService;

  ShoppingRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<List<ShoppingItemModel>> getItems() async {
    final result = await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {'action': 'list'},
    );

    if (result == null) return [];

    // Edge Function zwraca { success: true, data: [...] }
    final data = result is Map ? result['data'] : result;
    if (data == null) return [];
    
    final List<dynamic> list = data is List ? data : [];
    return list
        .map((e) => ShoppingItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItem(String name, double quantity, String unit) async {
    await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {
        'action': 'add',
        'name': name,
        'quantity': quantity,
        'unit': unit,
      },
    );
  }

  Future<void> markPurchased(String itemId) async {
    await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {
        'action': 'purchased',
        'item_id': itemId,
      },
    );
  }

  Future<void> deleteItem(String itemId) async {
    await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {
        'action': 'delete',
        'item_id': itemId,
      },
    );
  }

  Future<void> clearPurchased() async {
    await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {'action': 'clear_purchased'},
    );
  }

  Future<void> moveToPantry() async {
    await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {'action': 'move_to_pantry'},
    );
  }
}
