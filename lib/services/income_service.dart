import '../data/models/income_model.dart';

class IncomeService {
  static final List<Income> _incomes = [];
  
  // Get all incomes
  static List<Income> getAllIncomes() => List.from(_incomes);
  
  // Add new income
  static void addIncome(Income income) {
    _incomes.add(income);
  }
  
  // Update income
  static void updateIncome(String id, Income updatedIncome) {
    final index = _incomes.indexWhere((income) => income.id == id);
    if (index != -1) {
      _incomes[index] = updatedIncome;
    }
  }
  
  // Delete income
  static void deleteIncome(String id) {
    _incomes.removeWhere((income) => income.id == id);
  }
  
  // Get income by ID
  static Income? getIncomeById(String id) {
    try {
      return _incomes.firstWhere((income) => income.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get total income amount
  static double getTotalIncome() {
    return _incomes.fold(0.0, (sum, income) => sum + income.amount);
  }
  
  // Get incomes by month
  static List<Income> getIncomesByMonth(int month, int year) {
    return _incomes.where((income) => 
      income.date.month == month && income.date.year == year
    ).toList();
  }
  
  // Get incomes by category
  static List<Income> getIncomesByCategory(String categoryName) {
    return _incomes.where((income) => 
      income.category.name == categoryName
    ).toList();
  }
  
  // Get incomes by wallet
  static List<Income> getIncomesByWallet(String walletId) {
    return _incomes.where((income) => 
      income.walletId == walletId
    ).toList();
  }
  
  // Search incomes
  static List<Income> searchIncomes(String keyword) {
    String lowerKeyword = keyword.toLowerCase();
    return _incomes.where((income) =>
      income.title.toLowerCase().contains(lowerKeyword) ||
      income.description.toLowerCase().contains(lowerKeyword) ||
      income.category.name.toLowerCase().contains(lowerKeyword)
    ).toList();
  }
  
  // Get income statistics by category
  static Map<String, double> getTotalByCategory() {
    Map<String, double> result = {};
    for (var income in _incomes) {
      final key = income.category.name;
      result[key] = (result[key] ?? 0) + income.amount;
    }
    return result;
  }
}
