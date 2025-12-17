import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BookingModel>> getAllBookings(String userId) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
  }
}
