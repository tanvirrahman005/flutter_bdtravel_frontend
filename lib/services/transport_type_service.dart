import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class TransportTypeService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all transport types
  Future<List<TransportTypeModel>> getAllTransportTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/transport-types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<TransportTypeModel>((json) => TransportTypeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transport types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transport types: $e');
    }
  }

  // Create transport type (Admin only)
  Future<Map<String, dynamic>> createTransportType(TransportTypeModel type) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/transport-types'),
        headers: headers,
        body: json.encode(type.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Transport type created successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create transport type'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating transport type: $e'};
    }
  }

  // Update transport type (Admin only)
  Future<Map<String, dynamic>> updateTransportType(int typeId, TransportTypeModel type) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/transport-types/$typeId'),
        headers: headers,
        body: json.encode(type.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Transport type updated successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update transport type'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating transport type: $e'};
    }
  }

  // Delete transport type (Admin only)
  Future<Map<String, dynamic>> deleteTransportType(int typeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/transport-types/$typeId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Transport type deleted successfully'};
      } else {
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to delete transport type'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to delete transport type'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting transport type: $e'};
    }
  }
}
