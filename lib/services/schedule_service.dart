import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/schedule_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class ScheduleService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all schedules
  Future<List<ScheduleModel>> getAllSchedules() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/schedules'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map<ScheduleModel>((json) => ScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching schedules: $e');
    }
  }

  // Create schedule
  Future<Map<String, dynamic>> createSchedule(ScheduleModel schedule) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/schedules'),
        headers: headers,
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Schedule created successfully'};
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': data['message'] ?? 'Failed to create schedule'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating schedule: $e'};
    }
  }

  // Update schedule
  Future<Map<String, dynamic>> updateSchedule(int scheduleId, ScheduleModel schedule) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/schedules/$scheduleId'),
        headers: headers,
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Schedule updated successfully'};
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {'success': false, 'message': data['message'] ?? 'Failed to update schedule'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating schedule: $e'};
    }
  }

  // Delete schedule
  Future<Map<String, dynamic>> deleteSchedule(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/schedules/$scheduleId/delete'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Schedule deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete schedule'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting schedule: $e'};
    }
  }

  // Update schedule status
  Future<Map<String, dynamic>> updateScheduleStatus(int scheduleId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/schedules/$scheduleId/status?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Status updated to $status'};
      } else {
        return {'success': false, 'message': 'Failed to update status'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating status: $e'};
    }
  }
}
