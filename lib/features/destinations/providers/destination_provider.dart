import 'package:flutter/foundation.dart';
import '../models/destination_model.dart';
import '../services/destination_service.dart';

class DestinationProvider with ChangeNotifier {
  final DestinationService _service = DestinationService();

  List<DestinationModel> _destinations = [];
  bool _isLoading = false;
  String _error = '';

  List<DestinationModel> get destinations => _destinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<DestinationModel> get favorites =>
      _destinations.where((d) => d.isFavorite).toList();

  Future<void> fetchDestinations() async {
    _setLoading(true);
    _setError('');

    try {
      _destinations = await _service.getAllDestinations();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addDestination(DestinationModel destination) async {
    _setLoading(true);
    _setError('');

    try {
      final created = await _service.addDestination(destination);

      // ✅ optimistic add
      _destinations = [created, ..._destinations];
      notifyListeners();

      // ✅ refresh for ordered list
      await fetchDestinations();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateDestination(DestinationModel destination) async {
    _setLoading(true);
    _setError('');

    try {
      await _service.updateDestination(destination);

      // ✅ optimistic update
      final i = _destinations.indexWhere((d) => d.id == destination.id);
      if (i != -1) {
        _destinations = List.of(_destinations);
        _destinations[i] = destination;
        notifyListeners();
      }

      await fetchDestinations();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteDestination(String id) async {
    _setLoading(true);
    _setError('');

    try {
      await _service.deleteDestination(id);

      // ✅ optimistic remove
      _destinations = _destinations.where((d) => d.id != id).toList();
      notifyListeners();

      await fetchDestinations();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final i = _destinations.indexWhere((d) => d.id == id);
    if (i == -1) return;

    final current = _destinations[i];
    final updated = current.copyWith(isFavorite: !current.isFavorite);

    // ✅ instant UI update
    _destinations = List.of(_destinations);
    _destinations[i] = updated;
    notifyListeners();

    try {
      await _service.toggleFavorite(id, updated.isFavorite);
    } catch (e) {
      // rollback on failure
      _destinations[i] = current;
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String v) {
    _error = v;
    notifyListeners();
  }
}