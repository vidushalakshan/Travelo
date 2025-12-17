class TripModel {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String? notes;
  final List<String> activities;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.notes,
    this.activities = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budget': budget,
      'notes': notes,
      'activities': activities,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      destination: json['destination'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      budget: (json['budget'] ?? 0.0).toDouble(),
      notes: json['notes'],
      activities: List<String>.from(json['activities'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
