import 'dart:convert';
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/route_model.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:http/http.dart' as http;

class RouteService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<RouteModel>> getAllRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/routes'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => RouteModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load routes');
  }

  Future<List<RouteModel>> getActiveRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/routes/active'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => RouteModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load active routes');
  }

  Future<Map<String, dynamic>> createRoute(RouteModel route) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/routes'),
      headers: await _getHeaders(),
      body: json.encode(route.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': 'Route created successfully'};
    } else {
      final errorData = json.decode(response.body);
      return {'success': false, 'message': errorData['message'] ?? 'Failed to create route'};
    }
  }

  Future<Map<String, dynamic>> updateRoute(int id, RouteModel route) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/routes/$id'),
      headers: await _getHeaders(),
      body: json.encode(route.toJson()),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Route updated successfully'};
    } else {
      final errorData = json.decode(response.body);
      return {'success': false, 'message': errorData['message'] ?? 'Failed to update route'};
    }
  }

  Future<Map<String, dynamic>> toggleRouteStatus(int id, bool activate) async {
    final endpoint = activate ? 'activate' : 'deactivate';
    final response = await http.patch(
      Uri.parse('$baseUrl/api/routes/$id/$endpoint'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Route ${activate ? 'activated' : 'deactivated'} successfully'
      };
    } else {
      final errorData = json.decode(response.body);
      return {'success': false, 'message': errorData['message'] ?? 'Failed to toggle route status'};
    }
  }

  Future<Map<String, dynamic>> deleteRoute(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/routes/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Route deleted successfully'};
    } else {
      return {'success': false, 'message': 'Failed to delete route'};
    }
  }
}
