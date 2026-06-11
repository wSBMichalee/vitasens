import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class FatSecretService {
  static const String _clientId = '8b2c29508b9a4c3eb759f69f667e9949';
  static const String _clientSecret = '0b9dd6a995eb46adb2a306fcc993bf61';
  static const String _tokenUrl = 'https://oauth.fatsecret.com/connect/token';
  static const String _apiUrl = 'https://platform.fatsecret.com/rest/server.api';

  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<String> _getToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final String basicAuth = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': 'Basic $basicAuth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'scope': 'basic',
      },
    );

    print('TOKEN REQUEST STATUS: ${response.statusCode}');
    print('TOKEN RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      final expiresIn = data['expires_in'] as int;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // 60s buffer
      return _accessToken!;
    } else {
      throw Exception('Failed to get FatSecret token');
    }
  }

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final token = await _getToken();
    final url = Uri.parse('$_apiUrl?method=foods.search&search_expression=${Uri.encodeComponent(query)}&format=json&max_results=20');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('SEARCH URL: $url');
    print('SEARCH STATUS: ${response.statusCode}');
    print('SEARCH RESPONSE: ${response.body.substring(0, min(500, response.body.length))}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      final foodsData = data['foods'];
      if (foodsData == null || foodsData['food'] == null) {
        return [];
      }

      var foodList = foodsData['food'];
      if (foodList is! List) {
        foodList = [foodList];
      }

      return List<Map<String, dynamic>>.from(foodList);
    } else {
      throw Exception('Failed to fetch foods from FatSecret');
    }
  }
}
