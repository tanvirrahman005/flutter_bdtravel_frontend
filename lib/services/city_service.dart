import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/city_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class CityService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all cities
  Future<List<CityModel>> getAllCities() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/cities'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<CityModel>((json) => CityModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  // Create city (Admin only)
  Future<Map<String, dynamic>> createCity(CityModel city) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/cities'),
        headers: headers,
        body: json.encode(city.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'City created successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create city'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating city: $e'};
    }
  }

  // Update city (Admin only)
  Future<Map<String, dynamic>> updateCity(int cityId, CityModel city) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/cities/$cityId'),
        headers: headers,
        body: json.encode(city.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'City updated successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update city'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating city: $e'};
    }
  }

  // Delete city (Admin only)
  Future<Map<String, dynamic>> deleteCity(int cityId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/cities/$cityId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'City deleted successfully'};
      } else {
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to delete city'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to delete city'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting city: $e'};
    }
  }

  // Toggle city active status (Admin only)
  Future<Map<String, dynamic>> toggleCityStatus(int cityId, bool activate) async {
    try {
      final headers = await _getHeaders();
      final endpoint = activate ? 'activate' : 'deactivate';
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/cities/$cityId/$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': activate ? 'City activated successfully' : 'City deactivated successfully'
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
