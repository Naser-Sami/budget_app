import '../models/enums.dart';
import '../models/summary_model.dart';
import '../repositories/i_budget_repository.dart';
import '../repositories/i_category_repository.dart';
import '../repositories/i_transaction_repository.dart';

class SummaryService {
  final ITransactionRepository _transactionRepository;
  final IBudgetRepository _budgetRepository;
  final ICategoryRepository _categoryRepository;

  SummaryService(
    this._transactionRepository,
    this._budgetRepository,
    this._categoryRepository,
  );

  /// Aggregates transaction and budget data into a [SummaryModel] for the given date range.
  Future<SummaryModel> getSummary(DateTime from, DateTime to) async {
    // 1. Get all transactions in range
    final transactions = await _transactionRepository.getByDateRange(from, to);

    // 2. Compute totalIncome
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // 3. Compute totalExpenses
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // 4. Compute netBalance
    final netBalance = totalIncome - totalExpenses;

    // 5. Get all categories
    final categories = await _categoryRepository.getAll();

    // 6. Build category breakdown
    final categoryBreakdown = <CategorySummaryModel>[];
    for (final category in categories) {
      // Compute total from already-fetched transactions — no extra DB call
      final categoryTotal = transactions
          .where((t) => t.categoryId == category.id && t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      // Get active budget — 1 lightweight query per category
      final activeBudget = await _budgetRepository.getActiveForCategory(category.id, from);

      // Skip categories with no activity and no budget
      if (categoryTotal == 0 && activeBudget == null) continue;

      categoryBreakdown.add(CategorySummaryModel(
        categoryId: category.id,
        categoryName: category.name,
        categoryType: category.type,
        total: categoryTotal,
        budgetLimit: activeBudget?.limitAmount,
        budgetRemaining: activeBudget != null ? activeBudget.limitAmount - categoryTotal : null,
        isOverBudget: activeBudget != null && categoryTotal > activeBudget.limitAmount,
      ));
    }

    // 9. Return SummaryModel
    return SummaryModel(
      periodStart: from,
      periodEnd: to,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netBalance: netBalance,
      categoryBreakdown: categoryBreakdown,
    );
  }
}
