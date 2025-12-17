import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/destination_provider.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<DestinationProvider>(context, listen: false).fetchDestinations()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destinations')),
      body: Consumer<DestinationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading destinations...');
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.destinations.isEmpty) {
            return const EmptyState(
              message: 'No destinations found',
              icon: Icons.place_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.destinations.length,
            itemBuilder: (context, index) {
              final destination = provider.destinations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.place)),
                  title: Text(destination.name),
                  subtitle: Text(destination.country),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${destination.rating}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
