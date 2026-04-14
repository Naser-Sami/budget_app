import '../models/budget_model.dart';
import 'repository_exceptions.dart';

abstract class IBudgetRepository {
  /// Returns all budgets.
  Future<List<BudgetModel>> getAll();

  /// Returns a single budget by ID, or null if not found.
  Future<BudgetModel?> getById(String id);

  /// Returns all budgets belonging to [categoryId].
  Future<List<BudgetModel>> getByCategory(String categoryId);

  /// Returns the active budget for [categoryId] at [date], or null if none exist.
  /// A budget is considered active if [date] falls within its period.
  Future<BudgetModel?> getActiveForCategory(String categoryId, DateTime date);

  /// Persists a new budget.
  ///
  /// Throws [ValidationException] if `budget.limitAmount <= 0`.
  /// Throws [ValidationException] if `budget.periodType == BudgetPeriod.custom` and
  /// `budget.periodEnd` is null or not after `budget.periodStart`.
  Future<void> create(BudgetModel budget);

  /// Updates an existing budget.
  ///
  /// Throws [EntityNotFoundException] if the ID does not exist.
  /// Throws [ValidationException] if `budget.limitAmount <= 0`.
  /// Throws [ValidationException] if `budget.periodType == BudgetPeriod.custom` and
  /// `budget.periodEnd` is null or not after `budget.periodStart`.
  Future<void> update(BudgetModel budget);

  /// Deletes a budget by ID. No-op if not found.
  Future<void> delete(String id);

  /// Reactive stream — emits the full budget list whenever any budget changes.
  Stream<List<BudgetModel>> watchAll();
}
