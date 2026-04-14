import 'package:drift/drift.dart';

import '../../models/budget_model.dart';
import '../../models/enums.dart';
import '../i_budget_repository.dart';
import '../repository_exceptions.dart';
import '../../local/app_database.dart';
import '../../local/daos/budget_dao.dart';

class DriftBudgetRepository implements IBudgetRepository {
  final BudgetDao _dao;

  DriftBudgetRepository(this._dao);

  BudgetModel _toModel(BudgetsTableData row) {
    return BudgetModel(
      id: row.id,
      categoryId: row.categoryId,
      limitAmount: row.limitAmount,
      periodType: BudgetPeriod.values.byName(row.periodType),
      periodStart: row.periodStart,
      periodEnd: row.periodEnd,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  BudgetsTableCompanion _toCompanion(BudgetModel model) {
    return BudgetsTableCompanion(
      id: Value(model.id),
      categoryId: Value(model.categoryId),
      limitAmount: Value(model.limitAmount),
      periodType: Value(model.periodType.name),
      periodStart: Value(model.periodStart),
      periodEnd: Value(model.periodEnd),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  void _validate(BudgetModel budget) {
    if (budget.limitAmount <= 0) {
      throw ValidationException('Budget limit amount must be strictly positive.');
    }

    if (budget.periodType == BudgetPeriod.custom) {
      if (budget.periodEnd == null) {
        throw ValidationException('Custom budget period must have an end date.');
      }
      if (!budget.periodEnd!.isAfter(budget.periodStart)) {
        throw ValidationException('Budget end date must be after start date.');
      }
    }
  }

  @override
  Future<List<BudgetModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<BudgetModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<BudgetModel>> getByCategory(String categoryId) async {
    final rows = await _dao.getByCategory(categoryId);
    return rows.map(_toModel).toList();
  }

  @override
  Future<BudgetModel?> getActiveForCategory(String categoryId, DateTime date) async {
    final row = await _dao.getActiveForCategory(categoryId, date);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> create(BudgetModel budget) async {
    _validate(budget);

    try {
      await _dao.insertBudget(_toCompanion(budget));
    } on Exception catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('unique') || message.contains('constraint failed')) {
        throw DuplicateEntityException(
            'Budget with ID ${budget.id} or unique violation occurred.');
      }
      rethrow;
    }
  }

  @override
  Future<void> update(BudgetModel budget) async {
    _validate(budget);

    final rowsUpdated = await _dao.updateBudget(_toCompanion(budget));
    if (rowsUpdated == 0) {
      throw EntityNotFoundException('Budget with ID ${budget.id} not found.');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _dao.deleteBudget(id);
  }

  @override
  Stream<List<BudgetModel>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toModel).toList());
  }
}
