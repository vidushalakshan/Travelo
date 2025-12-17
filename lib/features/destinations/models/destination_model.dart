class DestinationModel {
  final String id;
  final String name;
  final String country;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;
  final bool isFavorite;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.category,
    this.isFavorite = false,
  });

  DestinationModel copyWith({
    String? id,
    String? name,
    String? country,
    String? description,
    String? imageUrl,
    double? rating,
    String? category,
    bool? isFavorite,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Keep id in json for cache & debugging, but Firestore doc.id is the truth.
      'id': id,
      'name': name,
      'country': country,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  // ✅ Use this when reading Firestore so doc.id is always used
  factory DestinationModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return DestinationModel(
      id: docId,
      name: (data['name'] ?? '').toString(),
      country: (data['country'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      rating: _toDouble(data['rating']),
      category: (data['category'] ?? '').toString(),
      isFavorite: (data['isFavorite'] ?? false) == true,
    );
  }

  // ✅ For Hive/local cache (id comes from stored json)
  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      category: (json['category'] ?? '').toString(),
      isFavorite: (json['isFavorite'] ?? false) == true,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}