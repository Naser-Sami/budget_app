import '../models/budget_model.dart';
import '../models/enums.dart';
import '../models/summary_model.dart';
import '../repositories/i_transaction_repository.dart';

class BudgetService {
  final ITransactionRepository _transactionRepository;

  BudgetService(this._transactionRepository);

  /// Returns budget consumption for [categoryId] during the period of [budget].
  /// Returns null if no budget exists for the category.
  Future<CategorySummaryModel?> getConsumption(
    String categoryId,
    String categoryName,
    CategoryType categoryType,
    BudgetModel? budget,
  ) async {
    if (budget == null) return null;

    final DateTime start = budget.periodStart;
    late final DateTime end;

    switch (budget.periodType) {
      case BudgetPeriod.monthly:
        // Last millisecond of same month as start
        end = DateTime(start.year, start.month + 1, 0, 23, 59, 59, 999);
        break;
      case BudgetPeriod.weekly:
        // 6 days after start end of day
        final sixDaysLater = start.add(const Duration(days: 6));
        end = DateTime(sixDaysLater.year, sixDaysLater.month, sixDaysLater.day, 23, 59, 59, 999);
        break;
      case BudgetPeriod.custom:
        end = budget.periodEnd ?? start;
        break;
    }

    final transactions = await _transactionRepository.getByDateRange(start, end);

    final total = transactions
        .where((t) => t.categoryId == categoryId && t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return CategorySummaryModel(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryType: categoryType,
      total: total,
      budgetLimit: budget.limitAmount,
      budgetRemaining: budget.limitAmount - total,
      isOverBudget: total > budget.limitAmount,
    );
  }
}
