# Cubit Contracts: Budget App MVP - Cubit Presentation Layer

**Feature**: `002-cubit-presentation-layer`
**Date**: 2026-04-14

Each Cubit exposes a set of public methods. These contracts describe the method signatures, preconditions, postconditions, and the state transitions they trigger. UI widgets depend on these contracts, not on Cubit internals.

---

## TransactionCubit

**File**: `lib/features/transactions/cubit/transaction_cubit.dart`
**Dependencies**: `ITransactionRepository`

### Methods

| Method | Precondition | State emitted on success | State emitted on failure |
|--------|-------------|--------------------------|--------------------------|
| `loadAll()` | — | `TransactionLoading` → `TransactionLoaded(all, all, no filters)` | `TransactionError(msg, [])` |
| `addTransaction(TransactionModel)` | amount > 0, categoryId non-empty, accountId non-empty | `TransactionLoaded` with new item | `TransactionError(msg, last list)` |
| `updateTransaction(TransactionModel)` | item exists in loaded list | `TransactionLoaded` with updated item | `TransactionError(msg, last list)` |
| `deleteTransaction(String id)` | — | `TransactionLoaded` with item removed | `TransactionError(msg, last list)` |
| `applyFilters(TransactionFilters)` | Cubit in `TransactionLoaded` | `TransactionLoaded` with filtered subset | — (no async) |
| `clearFilters()` | Cubit in `TransactionLoaded` | `TransactionLoaded` with full list, empty filters | — (no async) |
| `dismissError()` | Cubit in `TransactionError` | `TransactionLoaded(lastKnownTransactions, ...)` | — |

### watchAll() stream behaviour
The Cubit subscribes to `ITransactionRepository.watchAll()` in its constructor. Every emission replaces the `transactions` list in `TransactionLoaded` and re-applies active filters. If the Cubit is in error state when a stream event arrives, it transitions to `TransactionLoaded` with the new list.

### Exception mapping

| Exception | Message |
|-----------|---------|
| `ValidationException` | Exception message (already human-readable) |
| `EntityNotFoundException` | "Transaction not found." |
| `EntityInUseException` | "This transaction is linked to other records and cannot be deleted." |
| Any other `Exception` | "An unexpected error occurred. Please try again." |

---

## BudgetCubit

**File**: `lib/features/budgets/cubit/budget_cubit.dart`
**Dependencies**: `IBudgetRepository`, `BudgetService`

### Methods

| Method | Precondition | State emitted on success | State emitted on failure |
|--------|-------------|--------------------------|--------------------------|
| `loadAll()` | — | `BudgetLoading` → `BudgetLoaded(list with consumption)` | `BudgetError(msg, [])` |
| `addBudget(BudgetModel)` | limitAmount > 0 | `BudgetLoaded` with new item | `BudgetError(msg, last list)` |
| `updateBudget(BudgetModel)` | item exists | `BudgetLoaded` with updated item | `BudgetError(msg, last list)` |
| `deleteBudget(String id)` | — | `BudgetLoaded` with item removed | `BudgetError(msg, last list)` |
| `dismissError()` | Cubit in `BudgetError` | `BudgetLoaded(lastKnownBudgets)` | — |

### watchAll() stream behaviour
Same as TransactionCubit — stream emissions refresh the list and recompute consumption data via `BudgetService`.

### Exception mapping

| Exception | Message |
|-----------|---------|
| `ValidationException` | Exception message |
| `EntityNotFoundException` | "Budget not found." |
| `DuplicateEntityException` | "A budget for this category and period already exists." |
| Any other `Exception` | "An unexpected error occurred. Please try again." |

---

## CategoryCubit

**File**: `lib/features/categories/cubit/category_cubit.dart`
**Dependencies**: `ICategoryRepository`

### Methods

| Method | Precondition | State emitted on success | State emitted on failure |
|--------|-------------|--------------------------|--------------------------|
| `loadAll()` | — | `CategoryLoading` → `CategoryLoaded` | `CategoryError(msg, [])` |
| `addCategory(CategoryModel)` | name non-empty | `CategoryLoaded` with new item | `CategoryError(msg, last list)` |
| `deleteCategory(String id)` | — | `CategoryLoaded` with item removed | `CategoryError(msg, last list)` |
| `dismissError()` | Cubit in `CategoryError` | `CategoryLoaded(lastKnownCategories)` | — |

### Exception mapping

| Exception | Message |
|-----------|---------|
| `ValidationException` | Exception message |
| `EntityNotFoundException` | "Category not found." |
| `ProtectedEntityException` | "Default categories cannot be deleted." |
| `EntityInUseException` | "This category is used by existing transactions and cannot be deleted." |
| `DuplicateEntityException` | "A category with this name already exists." |
| Any other `Exception` | "An unexpected error occurred. Please try again." |

---

## AccountCubit

**File**: `lib/features/accounts/cubit/account_cubit.dart`
**Dependencies**: `IAccountRepository`

### Methods

| Method | Precondition | State emitted on success | State emitted on failure |
|--------|-------------|--------------------------|--------------------------|
| `loadAll()` | — | `AccountLoading` → `AccountLoaded` | `AccountError(msg, [])` |
| `addAccount(AccountModel)` | name non-empty | `AccountLoaded` with new item | `AccountError(msg, last list)` |
| `updateAccount(AccountModel)` | item exists | `AccountLoaded` with updated item | `AccountError(msg, last list)` |
| `deleteAccount(String id)` | — | `AccountLoaded` with item removed | `AccountError(msg, last list)` |
| `dismissError()` | Cubit in `AccountError` | `AccountLoaded(lastKnownAccounts)` | — |

### Exception mapping

| Exception | Message |
|-----------|---------|
| `ValidationException` | Exception message |
| `EntityNotFoundException` | "Account not found." |
| `EntityInUseException` | "This account has transactions and cannot be deleted." |
| Any other `Exception` | "An unexpected error occurred. Please try again." |
