import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bd_travel/data/models/booking.dart';
import 'package:bd_travel/data/models/schedule.dart';
import 'package:bd_travel/data/models/city.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bd_travel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookingReference TEXT NOT NULL,
        scheduleId INTEGER NOT NULL,
        passengerName TEXT NOT NULL,
        passengerPhone TEXT NOT NULL,
        passengerEmail TEXT,
        totalAmount REAL NOT NULL,
        bookingStatus TEXT NOT NULL,
        bookingDate TEXT NOT NULL,
        fromCity TEXT NOT NULL,
        toCity TEXT NOT NULL,
        journeyDate TEXT NOT NULL,
        seatNumbers TEXT NOT NULL
      )
    ''');

    // Schedules table (for caching)
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY,
        routeName TEXT NOT NULL,
        fromCity TEXT NOT NULL,
        toCity TEXT NOT NULL,
        departureTime TEXT NOT NULL,
        arrivalTime TEXT NOT NULL,
        fare REAL NOT NULL,
        availableSeats INTEGER NOT NULL,
        totalSeats INTEGER NOT NULL,
        busType TEXT NOT NULL,
        companyName TEXT NOT NULL
      )
    ''');

    // Cities table
    await db.execute('''
      CREATE TABLE cities (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL
      )
    ''');

    // Seed mock cities
    await _seedCities(db);
    
    // Seed mock schedules
    await _seedSchedules(db);
  }

  Future _seedCities(Database db) async {
    final cities = [
      {'id': 1, 'name': 'Dhaka', 'code': 'DHA'},
      {'id': 2, 'name': 'Chittagong', 'code': 'CTG'},
      {'id': 3, 'name': 'Sylhet', 'code': 'SYL'},
      {'id': 4, 'name': 'Rajshahi', 'code': 'RJH'},
      {'id': 5, 'name': 'Khulna', 'code': 'KHL'},
      {'id': 6, 'name': 'Barisal', 'code': 'BRI'},
      {'id': 7, 'name': "Cox's Bazar", 'code': 'CXB'},
      {'id': 8, 'name': 'Rangpur', 'code': 'RNG'},
    ];

    for (var city in cities) {
      await db.insert('cities', city);
    }
  }

  Future _seedSchedules(Database db) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    final schedules = [
      {
        'id': 1,
        'routeName': 'Dhaka - Chittagong',
        'fromCity': 'Dhaka',
        'toCity': 'Chittagong',
        'departureTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0).toIso8601String(),
        'arrivalTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0).toIso8601String(),
        'fare': 800.0,
        'availableSeats': 25,
        'totalSeats': 40,
        'busType': 'AC',
        'companyName': 'Green Line',
      },
      {
        'id': 2,
        'routeName': 'Dhaka - Sylhet',
        'fromCity': 'Dhaka',
        'toCity': 'Sylhet',
        'departureTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 30).toIso8601String(),
        'arrivalTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0).toIso8601String(),
        'fare': 600.0,
        'availableSeats': 30,
        'totalSeats': 40,
        'busType': 'Non-AC',
        'companyName': 'Shyamoli Paribahan',
      },
      {
        'id': 3,
        'routeName': "Dhaka - Cox's Bazar",
        'fromCity': 'Dhaka',
        'toCity': "Cox's Bazar",
        'departureTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 22, 0).toIso8601String(),
        'arrivalTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day + 1, 8, 0).toIso8601String(),
        'fare': 1200.0,
        'availableSeats': 15,
        'totalSeats': 32,
        'busType': 'Sleeper AC',
        'companyName': 'Hanif Enterprise',
      },
      {
        'id': 4,
        'routeName': 'Dhaka - Rajshahi',
        'fromCity': 'Dhaka',
        'toCity': 'Rajshahi',
        'departureTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 7, 0).toIso8601String(),
        'arrivalTime': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13, 30).toIso8601String(),
        'fare': 550.0,
        'availableSeats': 20,
        'totalSeats': 40,
        'busType': 'AC',
        'companyName': 'Eagle Paribahan',
      },
    ];

    for (var schedule in schedules) {
      await db.insert('schedules', schedule);
    }
  }

  // Cities CRUD
  Future<List<City>> getAllCities() async {
    final db = await database;
    final result = await db.query('cities', orderBy: 'name');
    return result.map((map) => City.fromMap(map)).toList();
  }

  // Schedules CRUD
  Future<List<Schedule>> getAllSchedules() async {
    final db = await database;
    final result = await db.query('schedules');
    return result.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> searchSchedules(String fromCity, String toCity) async {
    final db = await database;
    final result = await db.query(
      'schedules',
      where: 'fromCity = ? AND toCity = ?',
      whereArgs: [fromCity, toCity],
    );
    return result.map((map) => Schedule.fromMap(map)).toList();
  }

  // Bookings CRUD
  Future<int> createBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final result = await db.query('bookings', orderBy: 'bookingDate DESC');
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  Future<Booking?> getBookingByReference(String reference) async {
    final db = await database;
    final result = await db.query(
      'bookings',
      where: 'bookingReference = ?',
      whereArgs: [reference],
    );
    if (result.isEmpty) return null;
    return Booking.fromMap(result.first);
  }

  Future<int> updateBookingStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'bookings',
      {'bookingStatus': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
