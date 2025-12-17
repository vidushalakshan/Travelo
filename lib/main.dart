import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/destinations/providers/destination_provider.dart';
import 'features/trips/providers/trip_provider.dart';
import 'features/bookings/providers/booking_provider.dart';
import 'features/expenses/providers/expense_provider.dart';

// Screens
import 'features/auth/screens/splash_screen.dart';

// Theme
import 'core/constants/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Fix AppCheck warning (best for emulator/development)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('app_data');
  await Hive.openBox('destinations');
  await Hive.openBox('trips');
  await Hive.openBox('bookings');
  await Hive.openBox('expenses');

  runApp(const TravelMateApp());
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'TravelMate',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}