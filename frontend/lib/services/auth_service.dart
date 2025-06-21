import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/auth/login'),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body:
              'grant_type=password&username=$username&password=$password&scope=&client_id=&client_secret=');

      if (response.statusCode == 401) {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData['detail']};
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        await _storage.write(key: 'token', value: token);

        // Get user details
        final userResponse = await http.get(
          Uri.parse('$_baseUrl/user'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          return {
            'success': true,
            'is_active': userData['User']['is_active'],
          };
        }
      }
      return {'success': false, 'error': 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'An error occurred'};
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  static Future<String?> getToken() => _storage.read(key: 'token');
}
