import 'package:flutter/foundation.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripProvider with ChangeNotifier {
  final TripService _service = TripService();
  
  List<TripModel> _trips = [];
  bool _isLoading = false;
  String _error = '';

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchTrips(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = await _service.getAllTrips(userId);
      _error = '';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
