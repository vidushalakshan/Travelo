import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ExpenseModel>> getAllExpenses(String userId) async {
    final snapshot = await _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => ExpenseModel.fromJson(doc.data())).toList();
  }
}
