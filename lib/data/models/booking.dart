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
    return Booking(
      id: map['id'],
      bookingReference: map['bookingReference'] ?? '',
      scheduleId: map['scheduleId'] ?? 0,
      passengerName: map['passengerName'] ?? '',
      passengerPhone: map['passengerPhone'] ?? '',
      passengerEmail: map['passengerEmail'],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      bookingStatus: map['bookingStatus'] ?? 'PENDING',
      bookingDate: DateTime.parse(map['bookingDate']),
      fromCity: map['fromCity'] ?? '',
      toCity: map['toCity'] ?? '',
      journeyDate: DateTime.parse(map['journeyDate']),
      seatNumbers: (map['seatNumbers'] as String).split(','),
    );
  }
}
