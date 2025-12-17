import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/providers/auth_provider.dart';
import '../auth/screens/login_screen.dart';
import '../bookings/screens/bookings_screen.dart';
import '../destinations/screens/destinations_screen.dart';
import '../trips/screens/trips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs = <Widget>[
    const DashboardTab(),
    const DestinationsScreen(),
    const TripsScreen(),
    const BookingsScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Show our AppBar only for Dashboard + Profile to avoid double AppBars
    final bool showTopAppBar = _selectedIndex == 0 || _selectedIndex == 4;

    return Scaffold(
      appBar: showTopAppBar
          ? AppBar(
              title: Text(_selectedIndex == 0 ? 'Travelo' : 'Profile'),
              centerTitle: false,
              actions: _selectedIndex == 0
                  ? [
                      IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // TODO: hook up search
                        },
                      ),
                    ]
                  : null,
            )
          : null,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IndexedStack(
            key: ValueKey<int>(_selectedIndex),
            index: _selectedIndex,
            children: _tabs,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place_rounded), label: 'Destinations'),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel_rounded), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

/// -------------------------
/// Dashboard (Blue UI)
/// -------------------------
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _HeroCard(
          title: 'Plan your next trip',
          subtitle: 'Explore destinations, save favorites, and track bookings.',
          icon: Icons.flight_takeoff_rounded,
          background: cs.primary.withOpacity(0.10),
          border: cs.primary.withOpacity(0.25),
        ),
        const SizedBox(height: 14),

        Text(
          'Quick actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),

        Row(
          children: const [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.explore_rounded,
                title: 'Explore',
                subtitle: 'Find places',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.card_travel_rounded,
                title: 'Trips',
                subtitle: 'Your plans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.book_online_rounded,
                title: 'Bookings',
                subtitle: 'Tickets/hotels',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.favorite_rounded,
                title: 'Favorites',
                subtitle: 'Saved places',
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Text(
          'Popular right now',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),

        // Professional placeholders (until you wire real data)
        _PlaceholderListItem(
          title: 'Beach escapes',
          subtitle: 'Sunny spots & relaxing stays',
          icon: Icons.beach_access_rounded,
        ),
        _PlaceholderListItem(
          title: 'Mountain adventures',
          subtitle: 'Hikes, views & cool weather',
          icon: Icons.terrain_rounded,
        ),
        _PlaceholderListItem(
          title: 'City breaks',
          subtitle: 'Food, culture & nightlife',
          icon: Icons.location_city_rounded,
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color border;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PlaceholderListItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: cs.primary),
        ],
      ),
    );
  }
}

/// -------------------------
/// Profile (Fix crash + logout red)
/// -------------------------
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  String _initial(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final cs = Theme.of(context).colorScheme;

    final displayName = (user?.displayName ?? '').trim();
    final email = (user?.email ?? '').trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.primary.withOpacity(0.15),
                child: Text(
                  _initial(displayName),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isNotEmpty ? displayName : 'User',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty ? email : 'No email',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _ProfileTile(
          icon: Icons.settings_rounded,
          title: 'Settings',
          subtitle: 'App preferences',
          onTap: () {
            // TODO: navigate
          },
        ),
        _ProfileTile(
          icon: Icons.help_rounded,
          title: 'Help & Support',
          subtitle: 'Get assistance',
          onTap: () {
            // TODO: navigate
          },
        ),
        _ProfileTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy',
          subtitle: 'Terms & policy',
          onTap: () {
            // TODO: navigate
          },
        ),

        const SizedBox(height: 18),

        ElevatedButton.icon(
          onPressed: () async {
            await authProvider.logout();
            if (!context.mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.14)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right_rounded, color: cs.primary),
      ),
    );
  }
}