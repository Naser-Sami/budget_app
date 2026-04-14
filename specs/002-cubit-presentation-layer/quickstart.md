# Quickstart: Budget App MVP - Cubit Presentation Layer

**Feature**: `002-cubit-presentation-layer`
**Date**: 2026-04-14

---

## Prerequisites

Feature 001 (Data Layer) must be complete and passing `flutter analyze`. The following are expected to exist and be stable:
- `lib/data/models/` — all four model classes + enums
- `lib/data/repositories/` — all four interfaces + implementations
- `lib/data/services/budget_service.dart`
- `lib/main.dart` with `MultiRepositoryProvider`

Run before starting:

```bash
flutter pub get
flutter analyze
```

Both must succeed with no errors.

---

## Running tests

```bash
flutter test test/features/
```

Individual Cubit test suites:

```bash
flutter test test/features/transactions/cubit/transaction_cubit_test.dart
flutter test test/features/budgets/cubit/budget_cubit_test.dart
flutter test test/features/categories/cubit/category_cubit_test.dart
flutter test test/features/accounts/cubit/account_cubit_test.dart
```

---

## Manual smoke test (in-app)

After wiring Cubits into `main.dart`, launch the app:

```bash
flutter run
```

1. **TransactionCubit** — Breakpoint or print log at `emit(TransactionLoaded(...))`. Verify it fires on app start with an empty list (or seeded data).
2. **CategoryCubit** — Verify seeded default categories appear in `CategoryLoaded.categories` on first load.
3. **BudgetCubit** — Create a budget via repository directly (or via the Cubit method). Verify `BudgetLoaded` contains a `BudgetWithConsumption` entry.
4. **Error path** — Temporarily mock a repository to throw `ValidationException`. Verify the Cubit emits `*Error` with the correct message.

---

## Key test scenarios (from spec)

### TransactionCubit

```
Scenario: initial load
  Given: empty or seeded database
  When:  TransactionCubit is created and loadAll() called
  Then:  emits [TransactionLoading, TransactionLoaded(transactions: [...], filtered: [...], activeFilters: none)]

Scenario: add valid transaction
  When:  addTransaction(validModel) called in Loaded state
  Then:  emits TransactionLoaded with the new item included

Scenario: add invalid transaction (amount = 0)
  When:  addTransaction(model with amount 0)
  Then:  emits TransactionError with "Transaction amount must be greater than zero."
         list in error state equals last known list

Scenario: delete transaction
  When:  deleteTransaction(existingId)
  Then:  emits TransactionLoaded with that transaction removed

Scenario: apply date filter
  When:  applyFilters(TransactionFilters(from: X, to: Y))
  Then:  emits TransactionLoaded where filtered contains only transactions in [X, Y]
         transactions (full list) is unchanged
```

### BudgetCubit

```
Scenario: load with consumption
  When:  loadAll() called
  Then:  emits BudgetLoaded where each BudgetWithConsumption has correct amountSpent

Scenario: add budget with limit <= 0
  When:  addBudget(model with limitAmount 0)
  Then:  emits BudgetError("Budget limit must be greater than zero.")
```

### CategoryCubit

```
Scenario: delete default category
  When:  deleteCategory(id of a default category)
  Then:  emits CategoryError("Default categories cannot be deleted.")
         list unchanged

Scenario: delete custom category
  When:  deleteCategory(id of a user-created category)
  Then:  emits CategoryLoaded with that category removed
```

### AccountCubit

```
Scenario: delete account with transactions
  When:  deleteAccount(id of account referenced by a transaction)
  Then:  emits AccountError("This account has transactions and cannot be deleted.")

Scenario: add account with empty name
  When:  addAccount(model with empty name)
  Then:  emits AccountError("Account name cannot be empty.")
```

---

## Wiring Cubits in main.dart

Add inside the existing `MultiRepositoryProvider.child` (or wrap as `MultiBlocProvider`):

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => TransactionCubit(
        context.read<ITransactionRepository>(),
      )..loadAll(),
    ),
    BlocProvider(
      create: (context) => BudgetCubit(
        context.read<IBudgetRepository>(),
        context.read<BudgetService>(),
      )..loadAll(),
    ),
    BlocProvider(
      create: (context) => CategoryCubit(
        context.read<ICategoryRepository>(),
      )..loadAll(),
    ),
    BlocProvider(
      create: (context) => AccountCubit(
        context.read<IAccountRepository>(),
      )..loadAll(),
    ),
  ],
  child: const MyApp(),
)
```
