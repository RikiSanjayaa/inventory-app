import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://127.0.0.1:8000';

  static Future<bool> login(String username, String password) async {
    final response = await http.post(Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body:
            'grant_type=password&username=$username&password=$password&scope=&client_id=&client_secret=');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'token', value: data['access_token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  static Future<String?> getToken() => _storage.read(key: 'token');
}
