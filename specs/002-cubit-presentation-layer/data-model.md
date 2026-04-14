# Data Model: Budget App MVP - Cubit Presentation Layer

**Feature**: `002-cubit-presentation-layer`
**Date**: 2026-04-14

All state classes use Dart 3 `sealed` hierarchies. Every concrete subclass `extends Equatable`.

---

## TransactionState

**File**: `lib/features/transactions/cubit/transaction_state.dart`

```dart
sealed class TransactionState extends Equatable {}

// Emitted immediately on Cubit creation before any data loads.
final class TransactionInitial extends TransactionState {
  const TransactionInitial();
  @override List<Object?> get props => [];
}

// Emitted while the initial load (or a reload) is in progress.
final class TransactionLoading extends TransactionState {
  const TransactionLoading();
  @override List<Object?> get props => [];
}

// Emitted when data is available. Carries the full unfiltered list plus active filters.
final class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;    // full list from watchAll()
  final List<TransactionModel> filtered;        // result after applying activeFilters
  final TransactionFilters activeFilters;        // date range, category, account filters

  const TransactionLoaded({
    required this.transactions,
    required this.filtered,
    required this.activeFilters,
  });
  @override List<Object?> get props => [transactions, filtered, activeFilters];
}

// Emitted on any repository or validation exception.
final class TransactionError extends TransactionState {
  final String message;
  final List<TransactionModel> lastKnownTransactions; // retained so UI can show list + error

  const TransactionError({
    required this.message,
    required this.lastKnownTransactions,
  });
  @override List<Object?> get props => [message, lastKnownTransactions];
}
```

### TransactionFilters (value object)

```dart
final class TransactionFilters extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final String? categoryId;
  final String? accountId;

  const TransactionFilters({this.from, this.to, this.categoryId, this.accountId});

  bool get isActive => from != null || to != null || categoryId != null || accountId != null;

  @override List<Object?> get props => [from, to, categoryId, accountId];
}
```

---

## BudgetState

**File**: `lib/features/budgets/cubit/budget_state.dart`

```dart
sealed class BudgetState extends Equatable {}

final class BudgetInitial extends BudgetState {
  const BudgetInitial();
  @override List<Object?> get props => [];
}

final class BudgetLoading extends BudgetState {
  const BudgetLoading();
  @override List<Object?> get props => [];
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
  @override List<Object?> get props => [budget, amountSpent, remaining, isOverBudget];
}

final class BudgetLoaded extends BudgetState {
  final List<BudgetWithConsumption> budgets;

  const BudgetLoaded({required this.budgets});
  @override List<Object?> get props => [budgets];
}

final class BudgetError extends BudgetState {
  final String message;
  final List<BudgetWithConsumption> lastKnownBudgets;

  const BudgetError({required this.message, required this.lastKnownBudgets});
  @override List<Object?> get props => [message, lastKnownBudgets];
}
```

---

## CategoryState

**File**: `lib/features/categories/cubit/category_state.dart`

```dart
sealed class CategoryState extends Equatable {}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
  @override List<Object?> get props => [];
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
  @override List<Object?> get props => [];
}

final class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryLoaded({required this.categories});
  @override List<Object?> get props => [categories];
}

final class CategoryError extends CategoryState {
  final String message;
  final List<CategoryModel> lastKnownCategories;

  const CategoryError({required this.message, required this.lastKnownCategories});
  @override List<Object?> get props => [message, lastKnownCategories];
}
```

---

## AccountState

**File**: `lib/features/accounts/cubit/account_state.dart`

```dart
sealed class AccountState extends Equatable {}

final class AccountInitial extends AccountState {
  const AccountInitial();
  @override List<Object?> get props => [];
}

final class AccountLoading extends AccountState {
  const AccountLoading();
  @override List<Object?> get props => [];
}

final class AccountLoaded extends AccountState {
  final List<AccountModel> accounts;

  const AccountLoaded({required this.accounts});
  @override List<Object?> get props => [accounts];
}

final class AccountError extends AccountState {
  final String message;
  final List<AccountModel> lastKnownAccounts;

  const AccountError({required this.message, required this.lastKnownAccounts});
  @override List<Object?> get props => [message, lastKnownAccounts];
}
```

---

## Entity Relationships (Feature 001 → Feature 002)

| Feature 002 type | Wraps Feature 001 type |
|---|---|
| `TransactionLoaded.transactions` | `List<TransactionModel>` |
| `BudgetWithConsumption.budget` | `BudgetModel` |
| `CategoryLoaded.categories` | `List<CategoryModel>` |
| `AccountLoaded.accounts` | `List<AccountModel>` |

All model types are immutable Equatable classes from `lib/data/models/`. Cubits never modify models — they replace the list in state.

---

## Validation Rules (enforced in Cubit before calling repository)

| Entity | Rule | Error message |
|---|---|---|
| Transaction | `amount > 0` | "Transaction amount must be greater than zero." |
| Transaction | `categoryId` non-empty | "A category must be selected." |
| Transaction | `accountId` non-empty | "An account must be selected." |
| Budget | `limitAmount > 0` | "Budget limit must be greater than zero." |
| Category | `name` non-empty | "Category name cannot be empty." |
| Account | `name` non-empty | "Account name cannot be empty." |

Repository typed exceptions are additionally caught and mapped to messages (see contracts).
