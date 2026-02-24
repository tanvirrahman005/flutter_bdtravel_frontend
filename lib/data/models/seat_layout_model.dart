import 'package:bd_travel/data/models/vehicle_model.dart';

class SeatLayoutModel {
  final int id;
  final VehicleModel vehicle;
  final String seatNumber;
  final String seatType; // 'REGULAR', 'PREMIUM', 'BUSINESS'
  final String deckLevel; // 'LOWER', 'UPPER'
  final int? rowPosition;
  final int? columnPosition;
  final bool isAvailable;

  SeatLayoutModel({
    required this.id,
    required this.vehicle,
    required this.seatNumber,
    this.seatType = 'REGULAR',
    this.deckLevel = 'LOWER',
    this.rowPosition,
    this.columnPosition,
    this.isAvailable = true,
  });

  factory SeatLayoutModel.fromJson(Map<String, dynamic> json) {
    return SeatLayoutModel(
      id: json['id'],
      vehicle: VehicleModel.fromJson(json['vehicle']),
      seatNumber: json['seatNumber'] ?? '',
      seatType: json['seatType'] ?? 'REGULAR',
      deckLevel: json['deckLevel'] ?? 'LOWER',
      rowPosition: json['rowPosition'],
      columnPosition: json['columnPosition'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle': {'id': vehicle.id}, // Only send ID for relationship
      'seatNumber': seatNumber,
      'seatType': seatType,
      'deckLevel': deckLevel,
      'rowPosition': rowPosition,
      'columnPosition': columnPosition,
      'isAvailable': isAvailable,
    };
  }
}
