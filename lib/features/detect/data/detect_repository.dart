import 'package:supabase_flutter/supabase_flutter.dart';

class DetectRepository {
  final SupabaseClient _supabase;

  DetectRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> detectFood({
    required String photoBase64,
    String? mealTime,
    String? mealDate,
  }) async {
    final response = await _supabase.functions.invoke(
      'detect-food',
      body: {
        'action': 'detect',
        'photoBase64': photoBase64,
        if (mealTime != null) 'mealTime': mealTime,
        if (mealDate != null) 'mealDate': mealDate,
      },
    ).timeout(const Duration(seconds: 15), onTimeout: () {
      throw Exception('Connection timed out. Please try again later.');
    });

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> scanFridge({
    required String imageBase64,
    required String mode,
  }) async {
    final response = await _supabase.functions.invoke(
      'scan-fridge',
      body: {'imageBase64': imageBase64, 'mode': mode},
    ).timeout(const Duration(seconds: 30));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    final response = await _supabase.functions.invoke(
      'scan-barcode',
      body: {
        'action': 'lookup',
        'barcode': barcode,
      },
    ).timeout(const Duration(seconds: 15), onTimeout: () {
      throw Exception('Connection timed out. Please try again later.');
    });

    return response.data as Map<String, dynamic>;
  }
}
