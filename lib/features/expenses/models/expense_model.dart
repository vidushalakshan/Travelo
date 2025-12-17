enum ExpenseCategory { food, transport, accommodation, entertainment, shopping, other }

class ExpenseModel {
  final String id;
  final String userId;
  final String? tripId;
  final ExpenseCategory category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    this.tripId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tripId': tripId,
      'category': category.toString(),
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      tripId: json['tripId'],
      category: _parseCategoryFromString(json['category'].toString()),
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static ExpenseCategory _parseCategoryFromString(String category) {
    if (category.contains('food')) return ExpenseCategory.food;
    if (category.contains('transport')) return ExpenseCategory.transport;
    if (category.contains('accommodation')) return ExpenseCategory.accommodation;
    if (category.contains('entertainment')) return ExpenseCategory.entertainment;
    if (category.contains('shopping')) return ExpenseCategory.shopping;
    return ExpenseCategory.other;
  }
}
