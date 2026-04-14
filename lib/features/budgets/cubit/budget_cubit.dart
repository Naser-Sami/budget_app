import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/budget_model.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/i_budget_repository.dart';
import '../../../data/repositories/repository_exceptions.dart';
import '../../../data/services/budget_service.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final IBudgetRepository _repository;
  final BudgetService _budgetService;
  late final StreamSubscription<List<BudgetModel>> _subscription;

  BudgetCubit(this._repository, this._budgetService) : super(const BudgetInitial()) {
    _subscription = _repository.watchAll().listen((budgets) async {
      final budgetsWithConsumption = await _buildWithConsumption(budgets);
      emit(BudgetLoaded(budgets: budgetsWithConsumption));
    });
  }

  Future<void> loadAll() async {
    emit(const BudgetLoading());
    try {
      final budgets = await _repository.getAll();
      final budgetsWithConsumption = await _buildWithConsumption(budgets);
      emit(BudgetLoaded(budgets: budgetsWithConsumption));
    } on Exception catch (e) {
      emit(BudgetError(
        message: _mapError(e),
        lastKnownBudgets: const [],
      ));
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      if (budget.limitAmount <= 0) {
        throw ValidationException('Budget limit must be greater than zero.');
      }
      await _repository.create(budget);
    } on Exception catch (e) {
      emit(BudgetError(
        message: _mapError(e),
        lastKnownBudgets: _currentBudgets,
      ));
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      if (budget.limitAmount <= 0) {
        throw ValidationException('Budget limit must be greater than zero.');
      }
      await _repository.update(budget);
    } on Exception catch (e) {
      emit(BudgetError(
        message: _mapError(e),
        lastKnownBudgets: _currentBudgets,
      ));
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _repository.delete(id);
    } on Exception catch (e) {
      emit(BudgetError(
        message: _mapError(e),
        lastKnownBudgets: _currentBudgets,
      ));
    }
  }

  void dismissError() {
    if (state is BudgetError) {
      final errorState = state as BudgetError;
      emit(BudgetLoaded(budgets: errorState.lastKnownBudgets));
    }
  }

  Future<List<BudgetWithConsumption>> _buildWithConsumption(
    List<BudgetModel> budgets,
  ) async {
    final results = <BudgetWithConsumption>[];
    for (final b in budgets) {
      // NOTE: Category name/type are required by BudgetService but not stored in BudgetModel.
      // We pass placeholders as only the numeric summary fields are needed for BudgetWithConsumption.
      final summary = await _budgetService.getConsumption(
        b.categoryId,
        '',
        CategoryType.expense,
        b,
      );
      results.add(BudgetWithConsumption(
        budget: b,
        amountSpent: summary?.total ?? 0,
        remaining: summary?.budgetRemaining ?? b.limitAmount,
        isOverBudget: summary?.isOverBudget ?? false,
      ));
    }
    return results;
  }

  String _mapError(Exception e) {
    if (e is ValidationException) return e.message;
    if (e is EntityNotFoundException) return 'Budget not found.';
    if (e is DuplicateEntityException) {
      return 'A budget for this category and period already exists.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  List<BudgetWithConsumption> get _currentBudgets {
    final s = state;
    if (s is BudgetLoaded) return s.budgets;
    return const [];
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
