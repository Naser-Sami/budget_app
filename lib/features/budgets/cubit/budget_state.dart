import 'package:equatable/equatable.dart';
import '../../../data/models/budget_model.dart';

sealed class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

final class BudgetInitial extends BudgetState {
  const BudgetInitial();

  @override
  List<Object?> get props => [];
}

final class BudgetLoading extends BudgetState {
  const BudgetLoading();

  @override
  List<Object?> get props => [];
}

// BudgetWithConsumption wraps a BudgetModel with computed spend data.
final class BudgetWithConsumption extends Equatable {
  final BudgetModel budget;
  final double amountSpent;
  final double remaining;
  final bool isOverBudget;

  const BudgetWithConsumption({
    required this.budget,
    required this.amountSpent,
    required this.remaining,
    required this.isOverBudget,
  });

  @override
  List<Object?> get props => [budget, amountSpent, remaining, isOverBudget];
}

final class BudgetLoaded extends BudgetState {
  final List<BudgetWithConsumption> budgets;

  const BudgetLoaded({required this.budgets});

  @override
  List<Object?> get props => [budgets];
}

final class BudgetError extends BudgetState {
  final String message;
  final List<BudgetWithConsumption> lastKnownBudgets;

  const BudgetError({
    required this.message,
    required this.lastKnownBudgets,
  });

  @override
  List<Object?> get props => [message, lastKnownBudgets];
}
