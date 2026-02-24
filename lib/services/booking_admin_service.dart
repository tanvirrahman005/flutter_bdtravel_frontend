import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/booking.dart';
import 'package:bd_travel/services/storage_service.dart';

class BookingAdminService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all bookings
  Future<List<Booking>> getAllBookings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map<Booking>((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Update booking status
  Future<Map<String, dynamic>> updateBookingStatus(int bookingId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/$bookingId/status?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking status updated to $status'};
      } else {
        return {'success': false, 'message': 'Failed to update booking status'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating booking status: $e'};
    }
  }

  // Delete booking
  Future<Map<String, dynamic>> deleteBooking(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/$bookingId/delete'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Booking deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete booking'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting booking: $e'};
    }
  }
}
