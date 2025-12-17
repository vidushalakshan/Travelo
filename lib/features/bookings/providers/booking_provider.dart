import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();
  
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    notifyListeners();
    _bookings = await _service.getAllBookings(userId);
    _isLoading = false;
    notifyListeners();
  }
}
