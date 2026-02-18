import 'package:bd_travel/data/models/transport_company_model.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';

class VehicleModel {
  final int id;
  final TransportCompanyModel transportCompany;
  final TransportTypeModel transportType;
  final String vehicleNumber;
  final String? model;
  final int totalSeats;
  final String vehicleType; // 'LOWER' or 'UPPER'
  final String? facilities;
  final bool isActive;

  VehicleModel({
    required this.id,
    required this.transportCompany,
    required this.transportType,
    required this.vehicleNumber,
    this.model,
    required this.totalSeats,
    this.vehicleType = 'LOWER',
    this.facilities,
    this.isActive = true,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      transportCompany: TransportCompanyModel.fromJson(json['transportCompany']),
      transportType: TransportTypeModel.fromJson(json['transportType']),
      vehicleNumber: json['vehicleNumber'] ?? '',
      model: json['model'],
      totalSeats: json['totalSeats'] ?? 0,
      vehicleType: json['vehicleType'] ?? 'LOWER',
      facilities: json['facilities'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transportCompany': {'id': transportCompany.id},
      'transportType': {'id': transportType.id},
      'vehicleNumber': vehicleNumber,
      'model': model,
      'totalSeats': totalSeats,
      'vehicleType': vehicleType,
      'facilities': facilities,
      'isActive': isActive,
    };
  }
}
