import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularService {
  static const String _apiKey = 'dcce985313c142b180e72717a41059b8';
  static const String _baseUrl = 'https://api.spoonacular.com/food/ingredients';

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    final url = Uri.parse('$_baseUrl/search?query=${Uri.encodeComponent(query)}&number=20&apiKey=$_apiKey');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>? ?? [];
      
      final futures = results.map((item) async {
        final id = item['id'];
        final name = item['name'];
        final image = item['image'];
        
        final info = await _getIngredientInfo(id);
        
        return {
          'id': id,
          'name': name,
          'image': image != null ? 'https://spoonacular.com/cdn/ingredients_100x100/$image' : '',
          'calories': info['calories'],
          'protein': info['protein'],
          'carbs': info['carbs'],
          'fat': info['fat'],
          'aisle': info['aisle'],
        };
      });
      
      return await Future.wait(futures);
    } else {
      throw Exception('Failed to search ingredients');
    }
  }

  Future<Map<String, String>> _getIngredientInfo(int id) async {
    final url = Uri.parse('$_baseUrl/$id/information?amount=100&unit=grams&apiKey=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nutrients = data['nutrition']['nutrients'] as List<dynamic>? ?? [];
        
        String calories = '0kcal';
        String protein = '0g';
        String carbs = '0g';
        String fat = '0g';
        
        for (var n in nutrients) {
          final name = n['name'].toString().toLowerCase();
          final amount = n['amount'].toString();
          final unit = n['unit'].toString();
          if (name == 'calories') calories = '$amount$unit';
          if (name == 'protein') protein = '$amount$unit';
          if (name == 'carbohydrates') carbs = '$amount$unit';
          if (name == 'fat') fat = '$amount$unit';
        }
        
        String aisle = data['aisle']?.toString() ?? '';
        
        return {
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'aisle': aisle,
        };
      }
    } catch (_) {}
    return {
      'calories': '?', 'protein': '?', 'carbs': '?', 'fat': '?', 'aisle': ''
    };
  }
}
