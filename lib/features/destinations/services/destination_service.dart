import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/destination_model.dart';

class DestinationService {
  DestinationService({
    FirebaseFirestore? firestore,
    Box? destinationsBox,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _box = destinationsBox;

  final FirebaseFirestore _db;
  final Box? _box;

  static const String _collection = 'destinations';
  static const String _cacheKey = 'cached_destinations';

  Future<Box> _openBox() async {
    if (_box != null) return _box!;
    return Hive.openBox('destinations');
  }

  Future<List<DestinationModel>> getAllDestinations() async {
    try {
      final snapshot = await _db.collection(_collection).orderBy('name').get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return DestinationModel.fromFirestore(doc.id, data);
      }).toList();

      // Cache in Hive (as List<Map>)
      final box = await _openBox();
      await box.put(_cacheKey, list.map((d) => d.toJson()).toList());

      return list;
    } catch (_) {
      // Fallback to cache
      final box = await _openBox();
      final cached = box.get(_cacheKey, defaultValue: []);

      if (cached is List) {
        return cached
            .whereType<Map>()
            .map((m) => DestinationModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }

      // If cache shape is unexpected, return empty
      return [];
    }
  }

  Future<DestinationModel> addDestination(DestinationModel destination) async {
    // ✅ Generate id if empty
    final id = destination.id.trim().isEmpty ? const Uuid().v4() : destination.id.trim();
    final docRef = _db.collection(_collection).doc(id);

    final toSave = destination.copyWith(id: id);
    await docRef.set(toSave.toJson(), SetOptions(merge: true));

    return toSave;
  }

  Future<void> updateDestination(DestinationModel destination) async {
    final id = destination.id.trim();
    if (id.isEmpty) {
      throw Exception('Destination id is missing. Cannot update.');
    }

    // ✅ set(merge:true) works even if doc doesn't exist
    await _db.collection(_collection).doc(id).set(
          destination.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteDestination(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return;
    await _db.collection(_collection).doc(cleanId).delete();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return;

    await _db.collection(_collection).doc(cleanId).set(
      {'isFavorite': isFavorite},
      SetOptions(merge: true),
    );
  }
}