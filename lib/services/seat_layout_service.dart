import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/seat_layout_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class SeatLayoutService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all seats
  Future<List<SeatLayoutModel>> getAllSeats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/seats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<SeatLayoutModel>((json) => SeatLayoutModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching seats: $e');
    }
  }

  // Get seats by vehicle
  Future<List<SeatLayoutModel>> getSeatsByVehicle(int vehicleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/seats/vehicle/$vehicleId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<SeatLayoutModel>((json) => SeatLayoutModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seats for vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching seats for vehicle: $e');
    }
  }

  // Create seat
  Future<Map<String, dynamic>> createSeat(SeatLayoutModel seat) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/seats'),
        headers: headers,
        body: json.encode(seat.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Seat layout created successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create seat layout'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating seat layout: $e'};
    }
  }

  // Update seat
  Future<Map<String, dynamic>> updateSeat(int seatId, SeatLayoutModel seat) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/seats/$seatId'),
        headers: headers,
        body: json.encode(seat.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Seat layout updated successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update seat layout'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating seat layout: $e'};
    }
  }

  // Delete seat
  Future<Map<String, dynamic>> deleteSeat(int seatId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/seats/$seatId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Seat layout deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete seat layout'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting seat layout: $e'};
    }
  }

  // Toggle seat availability
  Future<Map<String, dynamic>> toggleSeatAvailability(int seatId, bool available) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/seats/$seatId/availability?available=$available'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': available ? 'Seat marked as available' : 'Seat marked as unavailable'
        };
      } else {
        return {'success': false, 'message': 'Failed to update seat availability'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating seat availability: $e'};
    }
  }

  // Get booked seats by schedule
  Future<List<SeatLayoutModel>> getBookedSeatsBySchedule(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/schedule/$scheduleId/booked-seats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<SeatLayoutModel>((json) => SeatLayoutModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load booked seats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching booked seats: $e');
    }
  }
}
