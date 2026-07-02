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

  Future<List<ShoppingItemModel>> getHistory() async {
    final userId = _supabaseService.userId;
    if (userId == null) return [];
    
    final data = await _supabaseService.client
        .from('shopping_list')
        .select('*')
        .eq('user_id', userId)
        .eq('is_purchased', true)
        .order('purchased_at', ascending: false);
        
    return (data as List)
        .map((e) => ShoppingItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItem(String name, double quantity, String unit) async {
    await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {
        'action': 'add',
        'ingredientName': name,
        'quantityNeeded': quantity,
        'unit': unit,
      },
    );
  }

  Future<int> addItemsBatch(List<Map<String, dynamic>> items) async {
    final result = await _supabaseService.invokeFunction(
      'manage-shopping-list',
      body: {
        'action': 'add_batch',
        'items': items.map((item) => {
          'ingredientName': item['name'],
          'quantityNeeded': item['quantity'] ?? 1.0,
          'unit': item['unit'] ?? 'szt',
        }).toList(),
      },
    );
    return (result?['added'] as int?) ?? 0;
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
        'itemId': itemId,
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
