import 'package:bd_travel/data/models/city_model.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';

class RouteModel {
  final int id;
  final String routeNumber;
  final TransportTypeModel transportType;
  final CityModel startCity;
  final CityModel endCity;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final bool isActive;

  RouteModel({
    required this.id,
    required this.routeNumber,
    required this.transportType,
    required this.startCity,
    required this.endCity,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.isActive,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? 0,
      routeNumber: json['routeNumber'] ?? '',
      transportType: TransportTypeModel.fromJson(json['transportType'] ?? {}),
      startCity: CityModel.fromJson(json['startCity'] ?? {}),
      endCity: CityModel.fromJson(json['endCity'] ?? {}),
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'routeNumber': routeNumber,
      'transportType': {'id': transportType.id},
      'startCity': {'id': startCity.id},
      'endCity': {'id': endCity.id},
      'distanceKm': distanceKm,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'isActive': isActive,
    };
    if (id != 0) {
      data['id'] = id;
    }
    return data;
  }
}
