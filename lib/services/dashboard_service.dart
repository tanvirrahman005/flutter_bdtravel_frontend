import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';

class DashboardService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }

  Future<String> downloadReport(String type, Map<String, String> params) async {
    try {
      final headers = await _getHeaders();
      
      String queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      String url = '${ApiConfig.baseUrl}/api/reports/$type?$queryString';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        String fileName = '${type}_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        return filePath;
      } else {
        throw Exception('Failed to download report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading report: $e');
    }
  }
}
