enum BookingType { hotel, flight }

class BookingModel {
  final String id;
  final String userId;
  final BookingType type;
  final String title;
  final DateTime bookingDate;
  final String confirmationNumber;
  final double amount;
  final String? notes;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.bookingDate,
    required this.confirmationNumber,
    required this.amount,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'bookingDate': bookingDate.toIso8601String(),
      'confirmationNumber': confirmationNumber,
      'amount': amount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'].toString().contains('hotel') ? BookingType.hotel : BookingType.flight,
      title: json['title'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      confirmationNumber: json['confirmationNumber'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
