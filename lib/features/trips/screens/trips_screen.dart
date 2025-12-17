import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    if (auth.currentUser != null) {
      Future.microtask(() => tripProvider.fetchTrips(auth.currentUser!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const LoadingIndicator();
          if (provider.trips.isEmpty) {
            return const EmptyState(
              message: 'No trips planned yet',
              icon: Icons.card_travel_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.trips.length,
            itemBuilder: (context, index) {
              final trip = provider.trips[index];
              return Card(
                child: ListTile(
                  title: Text(trip.title),
                  subtitle: Text(trip.destination),
                  trailing: Text('\$${trip.budget}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
