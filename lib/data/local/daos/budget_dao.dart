import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/budgets_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [BudgetsTable])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<List<BudgetsTableData>> getAll() {
    return select(budgetsTable).get();
  }

  Future<BudgetsTableData?> getById(String id) {
    return (select(budgetsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<BudgetsTableData>> getByCategory(String categoryId) {
    return (select(budgetsTable)..where((t) => t.categoryId.equals(categoryId))).get();
  }

  Future<BudgetsTableData?> getActiveForCategory(String categoryId, DateTime date) {
    return (select(budgetsTable)
          ..where((t) =>
              t.categoryId.equals(categoryId) &
              t.periodStart.isSmallerOrEqualValue(date) &
              (t.periodEnd.isNull() | t.periodEnd.isBiggerOrEqualValue(date))))
        .getSingleOrNull();
  }

  Future<void> insertBudget(BudgetsTableCompanion budget) {
    return into(budgetsTable).insert(budget);
  }

  Future<int> updateBudget(BudgetsTableCompanion budget) {
    return (update(budgetsTable)..where((t) => t.id.equals(budget.id.value)))
        .write(budget);
  }

  Future<void> deleteBudget(String id) {
    return (delete(budgetsTable)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<BudgetsTableData>> watchAll() {
    return select(budgetsTable).watch();
  }
}
