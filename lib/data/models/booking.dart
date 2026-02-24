class Booking {
  final int? id;
  final String bookingReference;
  final int scheduleId;
  final String passengerName;
  final String passengerPhone;
  final String? passengerEmail;
  final double totalAmount;
  final String bookingStatus; // PENDING, CONFIRMED, CANCELLED
  final DateTime bookingDate;
  final String fromCity;
  final String toCity;
  final DateTime journeyDate;
  final List<String> seatNumbers;

  Booking({
    this.id,
    required this.bookingReference,
    required this.scheduleId,
    required this.passengerName,
    required this.passengerPhone,
    this.passengerEmail,
    required this.totalAmount,
    required this.bookingStatus,
    required this.bookingDate,
    required this.fromCity,
    required this.toCity,
    required this.journeyDate,
    required this.seatNumbers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingReference': bookingReference,
      'scheduleId': scheduleId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerEmail': passengerEmail,
      'totalAmount': totalAmount,
      'bookingStatus': bookingStatus,
      'bookingDate': bookingDate.toIso8601String(),
      'fromCity': fromCity,
      'toCity': toCity,
      'journeyDate': journeyDate.toIso8601String(),
      'seatNumbers': seatNumbers.join(','),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking.fromJson(map);
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingReference: json['bookingReference'] ?? '',
      scheduleId: json['scheduleId'] ?? (json['schedule'] != null ? json['schedule']['id'] : 0),
      passengerName: json['passengerName'] ?? '',
      passengerPhone: json['passengerPhone'] ?? '',
      passengerEmail: json['passengerEmail'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      bookingStatus: json['bookingStatus'] ?? 'PENDING',
      bookingDate: DateTime.parse(json['bookingDate']),
      fromCity: json['fromCity'] ?? (json['schedule'] != null && json['schedule']['route'] != null ? json['schedule']['route']['startCity']['name'] : ''),
      toCity: json['toCity'] ?? (json['schedule'] != null && json['schedule']['route'] != null ? json['schedule']['route']['endCity']['name'] : ''),
      journeyDate: DateTime.parse(json['journeyDate'] ?? (json['schedule'] != null ? json['schedule']['departureTime'] : json['bookingDate'])),
      seatNumbers: json['seatNumbers'] != null 
          ? (json['seatNumbers'] is String ? (json['seatNumbers'] as String).split(',') : (json['seatNumbers'] as List).cast<String>())
          : (json['seats'] != null ? (json['seats'] as List).map((s) => s['seatLayout']['seatNumber'] as String).toList() : []),
    );
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
