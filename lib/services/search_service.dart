import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/schedule_model.dart';
import 'package:intl/intl.dart';

class SearchService {
  // Search schedules based on cities, date, and optional transport type
  Future<List<ScheduleModel>> searchSchedules({
    required int fromCityId,
    required int toCityId,
    required DateTime journeyDate,
    int? transportTypeId,
  }) async {
    try {
      // Format date to ISO format for the API
      final String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(journeyDate);
      
      String url = '${ApiConfig.baseUrl}/api/schedules/search?'
          'startCityId=$fromCityId'
          '&endCityId=$toCityId'
          '&departureDate=$formattedDate';
      
      if (transportTypeId != null) {
        url += '&transportTypeId=$transportTypeId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map<ScheduleModel>((json) => ScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error performing search: $e');
    }
  }
}
