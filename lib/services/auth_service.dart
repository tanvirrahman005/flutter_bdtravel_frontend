import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/services/storage_service.dart';

class AuthService {
  static const String _loginEndpoint = 'api/auth/login';
  static const String _registerEndpoint = 'api/auth/register';

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/$_loginEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token and user info
        await StorageService.saveToken(data['token']);
        await StorageService.saveUserData(
          userId: data['id'].toString(),
          username: data['username'],
          email: data['email'],
          role: data['role'],
        );

        return {
          'success': true,
          'data': data,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/$_registerEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user data
  Future<Map<String, String?>> getCurrentUser() async {
    return await StorageService.getUserData();
  }
}
