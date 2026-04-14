# Repository Interface Contracts

**Branch**: `001-budget-app-data-layer` | **Date**: 2026-04-14
**Purpose**: Define the stable data access contracts that the Bloc/Cubit layer depends on. These interfaces must remain stable regardless of the underlying storage implementation.

---

## ITransactionRepository

**Location**: `lib/data/repositories/i_transaction_repository.dart`

```dart
abstract class ITransactionRepository {
  /// Returns all transactions, newest first.
  Future<List<TransactionModel>> getAll();

  /// Returns a single transaction by ID, or null if not found.
  Future<TransactionModel?> getById(String id);

  /// Returns transactions with a date on or between [from] and [to], inclusive.
  Future<List<TransactionModel>> getByDateRange(DateTime from, DateTime to);

  /// Returns all transactions belonging to [categoryId].
  Future<List<TransactionModel>> getByCategory(String categoryId);

  /// Returns all transactions belonging to [accountId].
  Future<List<TransactionModel>> getByAccount(String accountId);

  /// Persists a new transaction. [transaction.id] must be a unique UUID.
  Future<void> create(TransactionModel transaction);

  /// Updates an existing transaction. Throws if ID not found.
  Future<void> update(TransactionModel transaction);

  /// Deletes a transaction by ID. No-op if not found.
  Future<void> delete(String id);

  /// Reactive stream — emits the full transaction list whenever any transaction changes.
  Stream<List<TransactionModel>> watchAll();
}
```

**Error contract**:
- `create` throws `DuplicateEntityException` if `id` already exists.
- `update` throws `EntityNotFoundException` if `id` does not exist.
- Both `create` and `update` throw `ValidationException` if `amount <= 0`.

---

## IBudgetRepository

**Location**: `lib/data/repositories/i_budget_repository.dart`

```dart
abstract class IBudgetRepository {
  Future<List<BudgetModel>> getAll();

  Future<BudgetModel?> getById(String id);

  /// Returns all budgets for [categoryId].
  Future<List<BudgetModel>> getByCategory(String categoryId);

  /// Returns the active budget for [categoryId] at [date], or null if none.
  Future<BudgetModel?> getActiveForCategory(String categoryId, DateTime date);

  Future<void> create(BudgetModel budget);

  Future<void> update(BudgetModel budget);

  Future<void> delete(String id);

  Stream<List<BudgetModel>> watchAll();
}
```

**Error contract**:
- `create` and `update` throw `ValidationException` if `limitAmount <= 0`.
- `create` and `update` throw `ValidationException` if `periodType == custom` and `periodEnd` is null or not after `periodStart`.

---

## ICategoryRepository

**Location**: `lib/data/repositories/i_category_repository.dart`

```dart
abstract class ICategoryRepository {
  Future<List<CategoryModel>> getAll();

  Future<CategoryModel?> getById(String id);

  /// Returns only system-seeded (default) categories.
  Future<List<CategoryModel>> getDefaults();

  /// Returns categories of the given [type] (income or expense).
  Future<List<CategoryModel>> getByType(CategoryType type);

  Future<void> create(CategoryModel category);

  Future<void> update(CategoryModel category);

  /// Throws [ProtectedEntityException] if category is a default or has transactions.
  Future<void> delete(String id);

  Stream<List<CategoryModel>> watchAll();
}
```

**Error contract**:
- `delete` throws `ProtectedEntityException` if `isDefault == true`.
- `delete` throws `EntityInUseException` if any Transaction references this category.
- `create` and `update` throw `ValidationException` if `name` is empty.
- `create` and `update` throw `DuplicateEntityException` if `name` already exists.

---

## IAccountRepository

**Location**: `lib/data/repositories/i_account_repository.dart`

```dart
abstract class IAccountRepository {
  Future<List<AccountModel>> getAll();

  Future<AccountModel?> getById(String id);

  Future<void> create(AccountModel account);

  Future<void> update(AccountModel account);

  /// Throws [EntityInUseException] if any Transaction references this account.
  Future<void> delete(String id);

  Stream<List<AccountModel>> watchAll();
}
```

**Error contract**:
- `delete` throws `EntityInUseException` if any Transaction references this account.
- `create` and `update` throw `ValidationException` if `name` is empty.

---

## Exception Types

All exceptions are defined in `lib/data/repositories/repository_exceptions.dart`.

| Exception | When thrown |
|-----------|-------------|
| `EntityNotFoundException` | `update` called with an ID that does not exist |
| `DuplicateEntityException` | `create` called with an ID or unique name that already exists |
| `ProtectedEntityException` | `delete` called on a system-default entity that may not be removed |
| `EntityInUseException` | `delete` called on an entity still referenced by child records |
| `ValidationException` | Field value violates a business rule (e.g., amount ≤ 0, empty name) |

---

## Service Contracts

### BudgetService

**Location**: `lib/data/services/budget_service.dart`

```dart
class BudgetService {
  BudgetService(this._transactionRepository, this._budgetRepository);

  /// Returns budget consumption for [categoryId] during the period of [budget].
  /// Returns null if no budget exists for the category.
  Future<CategorySummaryModel?> getConsumption(
    String categoryId,
    BudgetModel budget,
  );
}
```

### SummaryService

**Location**: `lib/data/services/summary_service.dart`

```dart
class SummaryService {
  SummaryService(
    this._transactionRepository,
    this._budgetRepository,
    this._categoryRepository,
  );

  /// Builds a full [SummaryModel] for all transactions between [from] and [to].
  Future<SummaryModel> getSummary(DateTime from, DateTime to);
}
```

### SeedService

**Location**: `lib/data/services/seed_service.dart`

```dart
class SeedService {
  SeedService(this._categoryRepository);

  /// Seeds default categories if none exist. Idempotent.
  Future<void> seedDefaultCategories();
}
```
