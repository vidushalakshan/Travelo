import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  
  double get totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);

  Future<void> fetchExpenses(String userId) async {
    _isLoading = true;
    notifyListeners();
    _expenses = await _service.getAllExpenses(userId);
    _isLoading = false;
    notifyListeners();
  }
}
