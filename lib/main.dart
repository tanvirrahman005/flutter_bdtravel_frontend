import 'package:flutter/material.dart';
import 'package:bd_travel/core/theme/app_theme.dart';
import 'package:bd_travel/core/constants/app_strings.dart';
import 'package:bd_travel/core/constants/app_routes.dart';
import 'package:bd_travel/features/home/screens/home_screen.dart';
import 'package:bd_travel/features/auth/screens/login_screen.dart';
import 'package:bd_travel/features/auth/screens/register_screen.dart';
import 'package:bd_travel/features/profile/screens/profile_screen.dart';
import 'package:bd_travel/features/bookings/screens/my_bookings_screen.dart';
import 'package:bd_travel/features/search/screens/search_results_screen.dart';
import 'package:bd_travel/features/booking/screens/seat_selection_screen.dart';
import 'package:bd_travel/features/booking/screens/booking_form_screen.dart';
import 'package:bd_travel/features/booking/screens/payment_screen.dart';
import 'package:bd_travel/data/models/booking.dart';
import 'package:bd_travel/data/models/schedule_model.dart';
import 'package:bd_travel/data/models/seat_layout_model.dart';
import 'package:bd_travel/features/admin/screens/user_list_screen.dart';
import 'package:bd_travel/features/admin/screens/transport_company_list_screen.dart';
import 'package:bd_travel/features/admin/screens/transport_type_list_screen.dart';
import 'package:bd_travel/features/admin/screens/city_list_screen.dart';
import 'package:bd_travel/features/admin/screens/vehicle_list_screen.dart';
import 'package:bd_travel/features/admin/screens/seat_layout_list_screen.dart';
import 'package:bd_travel/features/admin/screens/route_list_screen.dart';
import 'package:bd_travel/features/admin/screens/schedule_list_screen.dart';
import 'package:bd_travel/features/admin/screens/booking_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
              settings: settings,
            );
          case AppRoutes.login:
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: settings,
            );
          case AppRoutes.register:
            return MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
              settings: settings,
            );
          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
              settings: settings,
            );
          case AppRoutes.myBookings:
            return MaterialPageRoute(
              builder: (_) => const MyBookingsScreen(),
              settings: settings,
            );
          case AppRoutes.searchResults:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SearchResultsScreen(
                fromCityId: args['fromCityId'],
                fromCityName: args['fromCityName'],
                toCityId: args['toCityId'],
                toCityName: args['toCityName'],
                journeyDate: args['journeyDate'],
                transportTypeId: args['transportTypeId'],
                transportTypeName: args['transportTypeName'],
              ),
              settings: settings,
            );
          case AppRoutes.seatSelection:
            final schedule = settings.arguments as ScheduleModel;
            return MaterialPageRoute(
              builder: (_) => SeatSelectionScreen(schedule: schedule),
              settings: settings,
            );
          case AppRoutes.bookingForm:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => BookingFormScreen(
                schedule: args['schedule'] as ScheduleModel,
                selectedSeats: (args['selectedSeats'] as List).cast<SeatLayoutModel>(),
              ),
              settings: settings,
            );
          case AppRoutes.payment:
            final booking = settings.arguments as Booking;
            return MaterialPageRoute(
              builder: (_) => PaymentScreen(booking: booking),
              settings: settings,
            );
          case AppRoutes.userList:
            return MaterialPageRoute(
              builder: (_) => const UserListScreen(),
              settings: settings,
            );
          case AppRoutes.transportCompanies:
            return MaterialPageRoute(
              builder: (_) => const TransportCompanyListScreen(),
              settings: settings,
            );
          case AppRoutes.transportTypes:
            return MaterialPageRoute(
              builder: (_) => const TransportTypeListScreen(),
              settings: settings,
            );
          case AppRoutes.cities:
            return MaterialPageRoute(
              builder: (_) => const CityListScreen(),
              settings: settings,
            );
          case AppRoutes.vehicles:
            return MaterialPageRoute(
              builder: (_) => const VehicleListScreen(),
              settings: settings,
            );
          case AppRoutes.seatLayouts:
            return MaterialPageRoute(
              builder: (_) => const SeatLayoutListScreen(),
              settings: settings,
            );
          case AppRoutes.transportRoutes:
            return MaterialPageRoute(
              builder: (_) => const RouteListScreen(),
              settings: settings,
            );
          case AppRoutes.schedules:
            return MaterialPageRoute(
              builder: (_) => const ScheduleListScreen(),
              settings: settings,
            );
          case AppRoutes.adminBookings:
            return MaterialPageRoute(
              builder: (_) => const BookingListScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
