import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/user_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class UserService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all users (Admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/users';
      
      print('=== UserService Debug ===');
      print('URL: $url');
      print('Token: ${headers['Authorization']}');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('========================');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<UserModel>((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllUsers: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Update user role (Admin only)
  Future<Map<String, dynamic>> updateUserRole(int userId, String newRole) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/role'),
        headers: headers,
        body: json.encode({'role': newRole}),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User role updated successfully'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to update role'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating role: $e'};
    }
  }

  // Delete user (Admin only)
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User deleted successfully'};
      } else {
        // Try to decode error message if available
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to delete user'};
        } catch (_) {
           return {'success': false, 'message': 'Failed to delete user'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting user: $e'};
    }
  }

  // Toggle user active status (Admin only)
  Future<Map<String, dynamic>> toggleUserStatus(int userId, bool activate) async {
    try {
      final headers = await _getHeaders();
      final endpoint = activate ? 'activate' : 'deactivate';
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': activate ? 'User activated successfully' : 'User deactivated successfully'
        };
      } else {
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to update status'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to update status'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating status: $e'};
    }
  }
}
