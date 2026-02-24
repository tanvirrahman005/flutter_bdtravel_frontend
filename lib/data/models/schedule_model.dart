import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/data/models/route_model.dart';

class ScheduleModel {
  final int id;
  final VehicleModel vehicle;
  final RouteModel route;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double basePrice;
  final int availableSeats;
  final String status;

  ScheduleModel({
    required this.id,
    required this.vehicle,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.basePrice,
    required this.availableSeats,
    required this.status,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      vehicle: VehicleModel.fromJson(json['vehicle'] ?? {}),
      route: RouteModel.fromJson(json['route'] ?? {}),
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      availableSeats: json['availableSeats'] ?? 0,
      status: json['status'] ?? 'SCHEDULED',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'vehicle': {'id': vehicle.id},
      'route': {'id': route.id},
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'basePrice': basePrice,
      'availableSeats': availableSeats,
      'status': status,
    };
    if (id != 0) {
      data['id'] = id;
    }
    return data;
  }
}
