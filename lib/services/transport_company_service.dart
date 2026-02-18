import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bd_travel/services/api_config.dart';
import 'package:bd_travel/data/models/transport_company_model.dart';
import 'package:bd_travel/services/storage_service.dart';

class TransportCompanyService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all companies (Admin access - includes authentication)
  Future<List<TransportCompanyModel>> getAllCompanies() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/companies';
      print('=== TransportCompanyService Debug ===');
      print('Fetching companies from: $url');
      print('Auth Header: ${headers['Authorization']}');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=====================================');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<TransportCompanyModel>((json) => TransportCompanyModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllCompanies: $e');
      throw Exception('Error fetching companies: $e');
    }
  }

  // Get active companies (Public/Admin - for dropdowns and user selection)
  Future<List<TransportCompanyModel>> getActiveCompanies() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/api/companies/active';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<TransportCompanyModel>((json) => TransportCompanyModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load active companies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getActiveCompanies: $e');
      throw Exception('Error fetching active companies: $e');
    }
  }

  // Create company (Admin only)
  Future<Map<String, dynamic>> createCompany(TransportCompanyModel company) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/companies'),
        headers: headers,
        body: json.encode(company.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Company created successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to create company'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error creating company: $e'};
    }
  }

  // Update company (Admin only)
  Future<Map<String, dynamic>> updateCompany(int companyId, TransportCompanyModel company) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/companies/$companyId'),
        headers: headers,
        body: json.encode(company.toJson()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Company updated successfully'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to update company'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating company: $e'};
    }
  }

  // Delete company (Admin only)
  Future<Map<String, dynamic>> deleteCompany(int companyId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/companies/$companyId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Company deleted successfully'};
      } else {
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to delete company'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to delete company'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting company: $e'};
    }
  }

  // Toggle company active status (Admin only)
  Future<Map<String, dynamic>> toggleCompanyStatus(int companyId, bool activate) async {
    try {
      final headers = await _getHeaders();
      final endpoint = activate ? 'activate' : 'deactivate';
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/companies/$companyId/$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': activate ? 'Company activated successfully' : 'Company deactivated successfully'
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
