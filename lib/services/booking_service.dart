import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/booking.dart';
import 'package:bd_travel/services/storage_service.dart';

class BookingService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get current user's bookings
  Future<List<Booking>> getMyBookings() async {
    try {
      final userData = await StorageService.getUserData();
      final userId = userData['userId'];
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/user/$userId'),
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

  // Get booking details by ID
  Future<Booking> getBookingById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to load booking details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching booking details: $e');
    }
  }

  // Create booking with selected seats
  Future<Booking> createBookingWithSeats({
    required int scheduleId,
    required List<Map<String, dynamic>> selectedSeats,
    required String passengerName,
    required String passengerPhone,
    String? passengerEmail,
    String? passengerNid,
    required double totalAmount,
  }) async {
    try {
      final userData = await StorageService.getUserData();
      final userId = userData['userId'];
      final headers = await _getHeaders();

      final body = json.encode({
        'scheduleId': scheduleId,
        'userId': userId,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'passengerEmail': passengerEmail,
        'passengerNid': passengerNid,
        'totalAmount': totalAmount,
        'selectedSeats': selectedSeats,
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/create-with-seats'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(error['error'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Update booking status
  Future<Booking> updateBookingStatus(int bookingId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/$bookingId/status?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to update booking status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }
}
