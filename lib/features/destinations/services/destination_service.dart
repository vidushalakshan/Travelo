import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/destination_model.dart';

class DestinationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'destinations';

  Future<List<DestinationModel>> getAllDestinations() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      final destinations = snapshot.docs
          .map((doc) => DestinationModel.fromJson(doc.data()))
          .toList();

      // Cache in Hive
      final box = await Hive.openBox('destinations');
      await box.put('cached', destinations.map((d) => d.toJson()).toList());

      return destinations;
    } catch (e) {
      // Fallback to cache
      final box = await Hive.openBox('destinations');
      final cached = box.get('cached', defaultValue: []);
      return (cached as List).map((json) => DestinationModel.fromJson(json)).toList();
    }
  }

  Future<void> addDestination(DestinationModel destination) async {
    await _db.collection(_collection).doc(destination.id).set(destination.toJson());
  }

  Future<void> updateDestination(DestinationModel destination) async {
    await _db.collection(_collection).doc(destination.id).update(destination.toJson());
  }

  Future<void> deleteDestination(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
