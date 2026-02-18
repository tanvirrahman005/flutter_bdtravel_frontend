class Schedule {
  final int id;
  final String routeName;
  final String fromCity;
  final String toCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double fare;
  final int availableSeats;
  final int totalSeats;
  final String busType; // AC, Non-AC, Sleeper
  final String companyName;

  Schedule({
    required this.id,
    required this.routeName,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
    required this.availableSeats,
    required this.totalSeats,
    required this.busType,
    required this.companyName,
  });

  String get duration {
    final diff = arrivalTime.difference(departureTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeName': routeName,
      'fromCity': fromCity,
      'toCity': toCity,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'fare': fare,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'busType': busType,
      'companyName': companyName,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] ?? 0,
      routeName: map['routeName'] ?? '',
      fromCity: map['fromCity'] ?? '',
      toCity: map['toCity'] ?? '',
      departureTime: DateTime.parse(map['departureTime']),
      arrivalTime: DateTime.parse(map['arrivalTime']),
      fare: (map['fare'] ?? 0).toDouble(),
      availableSeats: map['availableSeats'] ?? 0,
      totalSeats: map['totalSeats'] ?? 0,
      busType: map['busType'] ?? '',
      companyName: map['companyName'] ?? '',
    );
  }
}
