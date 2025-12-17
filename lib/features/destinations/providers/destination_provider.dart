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

  Future<void> fetchDestinations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _destinations = await _service.getAllDestinations();
      _error = '';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDestination(DestinationModel destination) async {
    await _service.addDestination(destination);
    await fetchDestinations();
  }

  Future<void> updateDestination(DestinationModel destination) async {
    await _service.updateDestination(destination);
    await fetchDestinations();
  }

  Future<void> deleteDestination(String id) async {
    await _service.deleteDestination(id);
    await fetchDestinations();
  }
}
