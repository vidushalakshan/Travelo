import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/destination_model.dart';
import '../providers/destination_provider.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final TextEditingController _search = TextEditingController();
  int _filterIndex = 0;

  static const List<String> _filters = [
    'All',
    'Beach',
    'Nature',
    'Adventure',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationProvider>().fetchDestinations();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DestinationModel> _applyFilter(List<DestinationModel> items) {
    final q = _search.text.trim().toLowerCase();
    final f = _filters[_filterIndex];

    return items.where((d) {
      final matchesQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.country.toLowerCase().contains(q) ||
          d.category.toLowerCase().contains(q);

      final matchesFilter = f == 'All' || d.category == f;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> _openAddDialog() async {
    final created = await showDialog<DestinationModel>(
      context: context,
      builder: (_) => const _DestinationFormDialog(),
    );

    if (!mounted || created == null) return;

    final ok = await context.read<DestinationProvider>().addDestination(created);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Destination added' : context.read<DestinationProvider>().error),
      ),
    );
  }

  Future<void> _openEditDialog(DestinationModel existing) async {
    final updated = await showDialog<DestinationModel>(
      context: context,
      builder: (_) => _DestinationFormDialog(existing: existing),
    );

    if (!mounted || updated == null) return;

    final ok = await context.read<DestinationProvider>().updateDestination(updated);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Destination updated' : context.read<DestinationProvider>().error),
      ),
    );
  }

  Future<void> _confirmDelete(DestinationModel d) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete destination?'),
        content: Text('Delete "${d.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || result != true) return;

    final ok = await context.read<DestinationProvider>().deleteDestination(d.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Destination deleted' : context.read<DestinationProvider>().error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<DestinationProvider>(
      builder: (context, provider, _) {
        final items = _applyFilter(provider.destinations);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Destinations'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => provider.fetchDestinations(),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search destinations…',
                      prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                      suffixIcon: _search.text.trim().isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(Icons.close_rounded, color: cs.primary),
                              onPressed: () {
                                _search.clear();
                                setState(() {});
                              },
                            ),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary.withOpacity(0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary.withOpacity(0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary.withOpacity(0.45), width: 1.4),
                      ),
                    ),
                  ),
                ),

                // Filters
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final selected = i == _filterIndex;
                      return ChoiceChip(
                        label: Text(_filters[i]),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: cs.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: selected ? cs.primary : cs.onSurface,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: selected
                              ? cs.primary.withOpacity(0.35)
                              : cs.primary.withOpacity(0.12),
                        ),
                        onSelected: (_) => setState(() => _filterIndex = i),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.isLoading) return const _LoadingList();

                      if (provider.error.isNotEmpty) {
                        return _ErrorState(
                          message: provider.error,
                          onRetry: provider.fetchDestinations,
                        );
                      }

                      if (items.isEmpty) {
                        return _EmptyState(onAdd: _openAddDialog);
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final d = items[index];
                          return _DestinationCard(
                            item: d,
                            onEdit: () => _openEditDialog(d),
                            onFavorite: () => provider.toggleFavorite(d.id),
                            onDelete: () => _confirmDelete(d),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            onPressed: _openAddDialog,
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}

/// ----------------------
/// Card layout (exact requested)
/// ----------------------
class _DestinationCard extends StatelessWidget {
  final DestinationModel item;
  final VoidCallback onEdit;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _DestinationCard({
    required this.item,
    required this.onEdit,
    required this.onFavorite,
    required this.onDelete,
  });

  static const Color _chipBlue = Color(0xFF0D47A1); // dark blue

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // ✅ Edit + Delete in TOP RIGHT (edit left, delete right)
            Positioned(
              top: -6,
              right: -6,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_rounded, color: cs.primary),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with favorite top-right
                Stack(
                  children: [
                    Container(
                      width: 98,
                      height: 92,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.primary.withOpacity(0.18)),
                      ),
                      child: Icon(
                        Icons.image_rounded,
                        color: cs.primary.withOpacity(0.55),
                        size: 34,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.primary.withOpacity(0.15)),
                          ),
                          child: Icon(
                            item.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Padding(
                    // ✅ Leave space so text doesn't go under top-right icons
                    padding: const EdgeInsets.only(right: 72),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),

                        // ✅ Chips ONE row + horizontal scroll = never crop
                        SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _ChipPill(
                                icon: Icons.sell_rounded,
                                text: item.category,
                                color: _chipBlue,
                              ),
                              const SizedBox(width: 8),
                              _ChipPill(
                                icon: Icons.star_rounded,
                                text: item.rating.toStringAsFixed(1),
                                color: _chipBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ChipPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

/// Loading / empty / error
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 110,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withOpacity(0.12)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.primary.withOpacity(0.18)),
              ),
              child: Icon(Icons.place_rounded, color: cs.primary, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              'No destinations yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add your first destination.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_rounded, color: cs.primary),
              label: Text('Add destination', style: TextStyle(color: cs.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.primary, size: 44),
            const SizedBox(height: 10),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, color: cs.primary),
              label: Text('Retry', style: TextStyle(color: cs.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------
/// Form dialog (Add/Edit)
/// ----------------------
class _DestinationFormDialog extends StatefulWidget {
  final DestinationModel? existing;
  const _DestinationFormDialog({this.existing});

  @override
  State<_DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<_DestinationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _country =
      TextEditingController(text: widget.existing?.country ?? '');
  late final TextEditingController _category =
      TextEditingController(text: widget.existing?.category ?? 'Nature');
  late final TextEditingController _rating =
      TextEditingController(text: widget.existing?.rating.toString() ?? '4.5');
  late final TextEditingController _desc =
      TextEditingController(text: widget.existing?.description ?? '');

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _category.dispose();
    _rating.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Destination' : 'Edit Destination'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _country,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter country' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(
                  labelText: 'Category (Beach/Nature/Adventure/History)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _rating,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rating (0–5)'),
                validator: (v) {
                  final x = double.tryParse((v ?? '').trim());
                  if (x == null) return 'Enter number';
                  if (x < 0 || x > 5) return 'Rating must be 0–5';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: cs.primary)),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final model = DestinationModel(
              id: widget.existing?.id ?? '',
              name: _name.text.trim(),
              country: _country.text.trim(),
              description: _desc.text.trim(),
              imageUrl: widget.existing?.imageUrl ?? '',
              rating: double.tryParse(_rating.text.trim()) ?? 0,
              category: _category.text.trim().isEmpty ? 'Nature' : _category.text.trim(),
              isFavorite: widget.existing?.isFavorite ?? false,
            );

            Navigator.pop(context, model);
          },
          style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white),
          child: Text(widget.existing == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}