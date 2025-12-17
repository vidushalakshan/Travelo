import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<TripModel>> getAllTrips(String userId) async {
    final snapshot = await _db
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => TripModel.fromJson(doc.data())).toList();
  }
}
