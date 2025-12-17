import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/empty_state.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null) {
      Future.microtask(() => 
        Provider.of<BookingProvider>(context, listen: false).fetchBookings(auth.currentUser!.id)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.bookings.isEmpty) {
            return const EmptyState(message: 'No bookings found');
          }
          return ListView.builder(
            itemCount: provider.bookings.length,
            itemBuilder: (context, index) {
              final booking = provider.bookings[index];
              return ListTile(
                title: Text(booking.title),
                subtitle: Text(booking.confirmationNumber),
              );
            },
          );
        },
      ),
    );
  }
}
