import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class VehicleService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    if (token == null) {
      print('WARNING: Token is null in VehicleService');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all vehicles
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/vehicles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<VehicleModel>((json) => VehicleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  // Create vehicle (Admin only)
  Future<Map<String, dynamic>> createVehicle(VehicleModel vehicle) async {
    try {
      final headers = await _getHeaders();
      
      print('Creating vehicle with headers: $headers');
      print('Vehicle payload: ${json.encode(vehicle.toJson())}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/vehicles'),
        headers: headers,
        body: json.encode(vehicle.toJson()),
      );
      
      print('Create Response Status: ${response.statusCode}');
      print('Create Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Vehicle created successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create vehicle'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating vehicle: $e'};
    }
  }

  // Update vehicle (Admin only)
  Future<Map<String, dynamic>> updateVehicle(int vehicleId, VehicleModel vehicle) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/vehicles/$vehicleId'),
        headers: headers,
        body: json.encode(vehicle.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Vehicle updated successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update vehicle'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating vehicle: $e'};
    }
  }

  // Delete vehicle (Admin only)
  Future<Map<String, dynamic>> deleteVehicle(int vehicleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/vehicles/$vehicleId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Vehicle deleted successfully'};
      } else {
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to delete vehicle'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to delete vehicle'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting vehicle: $e'};
    }
  }

  // Toggle vehicle active status (Admin only)
  Future<Map<String, dynamic>> toggleVehicleStatus(int vehicleId, bool activate) async {
    try {
      final headers = await _getHeaders();
      final endpoint = activate ? 'activate' : 'deactivate';
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/vehicles/$vehicleId/$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': activate ? 'Vehicle activated successfully' : 'Vehicle deactivated successfully'
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
