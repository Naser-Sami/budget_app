# Tasks: Budget App MVP - Cubit Presentation Layer

**Input**: Design documents from `specs/002-cubit-presentation-layer/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Organization**: Tasks are grouped by user story. Each story delivers a fully functional, independently testable Cubit increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)
- No test tasks — tests were not requested in the feature specification

---

## Phase 1: Setup (Verify Prerequisites)

**Purpose**: Confirm the existing data layer is stable and accessible before writing any Cubit code.

- [x] T001 Run `flutter pub get` and `flutter analyze` in the repo root. Confirm zero errors. If errors exist, fix them before proceeding. No code changes expected — this is a gate check only.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No new foundational infrastructure is needed. The data layer from Feature 001 provides all repositories, models, and services that Cubits depend on.

**Data layer interfaces already in place**:
- `lib/data/repositories/i_transaction_repository.dart` — `ITransactionRepository`
- `lib/data/repositories/i_budget_repository.dart` — `IBudgetRepository`
- `lib/data/repositories/i_category_repository.dart` — `ICategoryRepository`
- `lib/data/repositories/i_account_repository.dart` — `IAccountRepository`
- `lib/data/services/budget_service.dart` — `BudgetService`
- `lib/data/repositories/repository_exceptions.dart` — all 5 typed exceptions

**⚠️ Checkpoint**: If `flutter analyze` failed in T001, stop here and fix. Otherwise proceed to user story phases.

---

## Phase 3: User Story 1 — View and Manage Transactions (Priority: P1) 🎯 MVP

**Goal**: Deliver a `TransactionCubit` that loads all transactions from the repository, supports create/update/delete, subscribes to the live `watchAll()` stream, and supports in-memory filtering by date range, category, and account — with full error state handling retaining the last known list.

**Independent Test**: Create a `TransactionCubit` with a mock `ITransactionRepository`, call `loadAll()`, and observe `[TransactionLoading, TransactionLoaded(...)]` emitted. Then call `addTransaction()` with amount = 0 and observe `TransactionError` with the original list preserved. See `quickstart.md` for full scenario list.

### Implementation for User Story 1

- [x] T002 [P] [US1] Create `lib/features/transactions/cubit/transaction_state.dart` — implement the sealed `TransactionState` hierarchy and the `TransactionFilters` value object exactly as specified in `data-model.md`:
  - `TransactionInitial extends TransactionState` — empty props
  - `TransactionLoading extends TransactionState` — empty props
  - `TransactionLoaded extends TransactionState` — fields: `List<TransactionModel> transactions` (full unfiltered list), `List<TransactionModel> filtered` (list after applying active filters), `TransactionFilters activeFilters`
  - `TransactionError extends TransactionState` — fields: `String message`, `List<TransactionModel> lastKnownTransactions`
  - `TransactionFilters extends Equatable` — fields: `DateTime? from`, `DateTime? to`, `String? categoryId`, `String? accountId`; getter `bool get isActive`
  - All concrete subclasses use `const` constructors and implement `List<Object?> get props` covering all fields
  - Imports: `package:equatable/equatable.dart`, `../../../data/models/transaction_model.dart`

- [x] T003 [US1] Create `lib/features/transactions/cubit/transaction_cubit.dart` — implement `TransactionCubit extends Cubit<TransactionState>` with all methods from `contracts/cubit-contracts.md`:
  - Constructor: accepts `ITransactionRepository _repository`; emits `TransactionInitial()`; subscribes to `_repository.watchAll()` stream, storing the subscription as `StreamSubscription<List<TransactionModel>> _subscription`; on each stream emission, if current state is `TransactionLoaded`, emit a new `TransactionLoaded` with the updated list re-applying active filters
  - `Future<void> loadAll()` — emit `TransactionLoading()`, await `_repository.getAll()`, emit `TransactionLoaded(transactions: result, filtered: result, activeFilters: const TransactionFilters())`; catch `Exception e` → emit `TransactionError(message: _mapError(e), lastKnownTransactions: const [])`
  - `Future<void> addTransaction(TransactionModel transaction)` — validate `transaction.amount > 0` (throw/emit `TransactionError('Transaction amount must be greater than zero.')`), validate `transaction.categoryId` non-empty, validate `transaction.accountId` non-empty; then await `_repository.add(transaction)`; let the `watchAll()` stream update state reactively; catch `Exception e` → emit `TransactionError(message: _mapError(e), lastKnownTransactions: _currentList)`
  - `Future<void> updateTransaction(TransactionModel transaction)` — same validation + await `_repository.update(transaction)`; reactive update via stream; catch `Exception e` → emit error
  - `Future<void> deleteTransaction(String id)` — await `_repository.delete(id)`; reactive update via stream; catch `Exception e` → emit error
  - `void applyFilters(TransactionFilters filters)` — synchronous; if state is `TransactionLoaded`, compute filtered list from `state.transactions` by applying filters (date range: `transaction.date >= from && transaction.date <= to`; categoryId: exact match if non-null; accountId: exact match if non-null); emit new `TransactionLoaded` with same `transactions`, new `filtered`, new `activeFilters`
  - `void clearFilters()` — if state is `TransactionLoaded`, emit `TransactionLoaded(transactions: state.transactions, filtered: state.transactions, activeFilters: const TransactionFilters())`
  - `void dismissError()` — if state is `TransactionError`, emit `TransactionLoaded(transactions: state.lastKnownTransactions, filtered: state.lastKnownTransactions, activeFilters: const TransactionFilters())`
  - `String _mapError(Exception e)` — private helper: if `e is ValidationException` return `e.message`; if `e is EntityNotFoundException` return `'Transaction not found.'`; if `e is EntityInUseException` return `'This transaction is linked to other records and cannot be deleted.'`; else return `'An unexpected error occurred. Please try again.'`
  - `List<TransactionModel> get _currentList` — private getter: returns `state is TransactionLoaded ? (state as TransactionLoaded).transactions : const []`
  - `@override Future<void> close()` — cancel `_subscription`, then `super.close()`
  - Imports: `dart:async`, `package:flutter_bloc/flutter_bloc.dart`, all repository interfaces, exception types, model types, state file

**Checkpoint**: `TransactionCubit` is fully functional. Verify with `flutter analyze` before proceeding. Manually construct a cubit with a real repository and confirm `loadAll()` transitions from `TransactionLoading` → `TransactionLoaded`.

---

## Phase 4: User Story 2 — View and Manage Budgets (Priority: P2)

**Goal**: Deliver a `BudgetCubit` that loads all budgets with their consumption data (amount spent, remaining, over-budget flag) via `BudgetService`, supports create/update/delete, subscribes to `watchAll()`, and handles errors with last-known-list retention.

**Independent Test**: Construct `BudgetCubit` with mock `IBudgetRepository` and `BudgetService`. Call `loadAll()` and observe `[BudgetLoading, BudgetLoaded(budgets: [BudgetWithConsumption(...)])]`. Call `addBudget()` with `limitAmount = 0` and observe `BudgetError('Budget limit must be greater than zero.')`.

### Implementation for User Story 2

- [x] T004 [P] [US2] Create `lib/features/budgets/cubit/budget_state.dart` — implement the sealed `BudgetState` hierarchy and the `BudgetWithConsumption` value object as specified in `data-model.md`:
  - `BudgetWithConsumption extends Equatable` — fields: `BudgetModel budget`, `double amountSpent`, `double remaining`, `bool isOverBudget`; `const` constructor; full props
  - `BudgetInitial extends BudgetState` — empty props
  - `BudgetLoading extends BudgetState` — empty props
  - `BudgetLoaded extends BudgetState` — field: `List<BudgetWithConsumption> budgets`
  - `BudgetError extends BudgetState` — fields: `String message`, `List<BudgetWithConsumption> lastKnownBudgets`
  - Imports: `package:equatable/equatable.dart`, `../../../data/models/budget_model.dart`

- [x] T005 [US2] Create `lib/features/budgets/cubit/budget_cubit.dart` — implement `BudgetCubit extends Cubit<BudgetState>` with all methods from `contracts/cubit-contracts.md`:
  - Constructor: accepts `IBudgetRepository _repository` and `BudgetService _budgetService`; emits `BudgetInitial()`; subscribes to `_repository.watchAll()` stream; on each emission recompute consumption via `_buildWithConsumption(budgets)` and emit `BudgetLoaded`
  - `Future<void> loadAll()` — emit `BudgetLoading()`, await `_repository.getAll()`, call `_buildWithConsumption(budgets)`, emit `BudgetLoaded(budgets: result)`; catch `Exception e` → emit `BudgetError(message: _mapError(e), lastKnownBudgets: const [])`
  - `Future<List<BudgetWithConsumption>> _buildWithConsumption(List<BudgetModel> budgets)` — for each budget call `_budgetService.getConsumption(budget.categoryId, ..., budget)` to get `CategorySummaryModel?`; build `BudgetWithConsumption(budget: b, amountSpent: summary?.total ?? 0, remaining: summary?.budgetRemaining ?? b.limitAmount, isOverBudget: summary?.isOverBudget ?? false)`
  - `Future<void> addBudget(BudgetModel budget)` — validate `budget.limitAmount > 0` → emit `BudgetError('Budget limit must be greater than zero.', _currentBudgets)` if invalid; else await `_repository.add(budget)`; reactive update via stream; catch `Exception e` → emit error
  - `Future<void> updateBudget(BudgetModel budget)` — same validation + `_repository.update(budget)`; reactive; catch exceptions
  - `Future<void> deleteBudget(String id)` — await `_repository.delete(id)`; reactive; catch exceptions
  - `void dismissError()` — if `BudgetError`, emit `BudgetLoaded(budgets: state.lastKnownBudgets)`
  - `String _mapError(Exception e)` — `ValidationException` → `e.message`; `EntityNotFoundException` → `'Budget not found.'`; `DuplicateEntityException` → `'A budget for this category and period already exists.'`; else → `'An unexpected error occurred. Please try again.'`
  - `List<BudgetWithConsumption> get _currentBudgets` — returns `state is BudgetLoaded ? (state as BudgetLoaded).budgets : const []`
  - `@override Future<void> close()` — cancel subscription, `super.close()`
  - Imports: `dart:async`, `package:flutter_bloc/flutter_bloc.dart`, repository interfaces, `BudgetService`, exception types, model types, state file

**Checkpoint**: `BudgetCubit` is fully functional. `flutter analyze` must pass.

---

## Phase 5: User Story 3 — Manage Categories (Priority: P3)

**Goal**: Deliver a `CategoryCubit` that loads all categories (defaults + user-created), supports add and delete with protection for default categories, subscribes to `watchAll()`, and handles all typed exceptions.

**Independent Test**: Construct `CategoryCubit` with mock `ICategoryRepository`. Call `loadAll()` → observe `[CategoryLoading, CategoryLoaded(categories: [...])]`. Call `deleteCategory(defaultCategoryId)` → repository throws `ProtectedEntityException` → observe `CategoryError('Default categories cannot be deleted.')` with list unchanged.

### Implementation for User Story 3

- [x] T006 [P] [US3] Create `lib/features/categories/cubit/category_state.dart` — implement the sealed `CategoryState` hierarchy as specified in `data-model.md`:
  - `CategoryInitial extends CategoryState` — empty props
  - `CategoryLoading extends CategoryState` — empty props
  - `CategoryLoaded extends CategoryState` — field: `List<CategoryModel> categories`
  - `CategoryError extends CategoryState` — fields: `String message`, `List<CategoryModel> lastKnownCategories`
  - All `const` constructors, full Equatable props
  - Imports: `package:equatable/equatable.dart`, `../../../data/models/category_model.dart`

- [x] T007 [US3] Create `lib/features/categories/cubit/category_cubit.dart` — implement `CategoryCubit extends Cubit<CategoryState>` with all methods from `contracts/cubit-contracts.md`:
  - Constructor: accepts `ICategoryRepository _repository`; emits `CategoryInitial()`; subscribes to `_repository.watchAll()` stream; on each emission emit `CategoryLoaded(categories: event)`
  - `Future<void> loadAll()` — emit `CategoryLoading()`, await `_repository.getAll()`, emit `CategoryLoaded(categories: result)`; catch `Exception e` → `CategoryError(message: _mapError(e), lastKnownCategories: const [])`
  - `Future<void> addCategory(CategoryModel category)` — validate `category.name.trim().isNotEmpty` → emit `CategoryError('Category name cannot be empty.', _currentCategories)` if blank; else await `_repository.add(category)`; reactive; catch exceptions
  - `Future<void> deleteCategory(String id)` — await `_repository.delete(id)`; reactive; catch `Exception e` → `CategoryError(_mapError(e), _currentCategories)`
  - `void dismissError()` — if `CategoryError`, emit `CategoryLoaded(categories: state.lastKnownCategories)`
  - `String _mapError(Exception e)` — `ValidationException` → `e.message`; `ProtectedEntityException` → `'Default categories cannot be deleted.'`; `EntityInUseException` → `'This category is used by existing transactions and cannot be deleted.'`; `EntityNotFoundException` → `'Category not found.'`; `DuplicateEntityException` → `'A category with this name already exists.'`; else → `'An unexpected error occurred. Please try again.'`
  - `List<CategoryModel> get _currentCategories` — returns `state is CategoryLoaded ? (state as CategoryLoaded).categories : const []`
  - `@override Future<void> close()` — cancel subscription, `super.close()`

**Checkpoint**: `CategoryCubit` is fully functional. `flutter analyze` must pass.

---

## Phase 6: User Story 4 — Manage Accounts (Priority: P4)

**Goal**: Deliver an `AccountCubit` that loads all accounts, supports add/update/delete with protection against deleting accounts that have transactions, subscribes to `watchAll()`, and handles all typed exceptions.

**Independent Test**: Construct `AccountCubit` with mock `IAccountRepository`. Call `loadAll()` → observe `[AccountLoading, AccountLoaded(accounts: [...])]`. Call `deleteAccount(idWithTransactions)` → repository throws `EntityInUseException` → observe `AccountError('This account has transactions and cannot be deleted.')` with list unchanged.

### Implementation for User Story 4

- [x] T008 [P] [US4] Create `lib/features/accounts/cubit/account_state.dart` — implement the sealed `AccountState` hierarchy as specified in `data-model.md`:
  - `AccountInitial extends AccountState` — empty props
  - `AccountLoading extends AccountState` — empty props
  - `AccountLoaded extends AccountState` — field: `List<AccountModel> accounts`
  - `AccountError extends AccountState` — fields: `String message`, `List<AccountModel> lastKnownAccounts`
  - All `const` constructors, full Equatable props
  - Imports: `package:equatable/equatable.dart`, `../../../data/models/account_model.dart`

- [x] T009 [US4] Create `lib/features/accounts/cubit/account_cubit.dart` — implement `AccountCubit extends Cubit<AccountState>` with all methods from `contracts/cubit-contracts.md`:
  - Constructor: accepts `IAccountRepository _repository`; emits `AccountInitial()`; subscribes to `_repository.watchAll()` stream; on each emission emit `AccountLoaded(accounts: event)`
  - `Future<void> loadAll()` — emit `AccountLoading()`, await `_repository.getAll()`, emit `AccountLoaded(accounts: result)`; catch `Exception e` → `AccountError(message: _mapError(e), lastKnownAccounts: const [])`
  - `Future<void> addAccount(AccountModel account)` — validate `account.name.trim().isNotEmpty` → emit `AccountError('Account name cannot be empty.', _currentAccounts)` if blank; else await `_repository.add(account)`; reactive; catch exceptions
  - `Future<void> updateAccount(AccountModel account)` — validate name non-empty + await `_repository.update(account)`; reactive; catch exceptions
  - `Future<void> deleteAccount(String id)` — await `_repository.delete(id)`; reactive; catch `Exception e` → `AccountError(_mapError(e), _currentAccounts)`
  - `void dismissError()` — if `AccountError`, emit `AccountLoaded(accounts: state.lastKnownAccounts)`
  - `String _mapError(Exception e)` — `ValidationException` → `e.message`; `EntityNotFoundException` → `'Account not found.'`; `EntityInUseException` → `'This account has transactions and cannot be deleted.'`; else → `'An unexpected error occurred. Please try again.'`
  - `List<AccountModel> get _currentAccounts` — returns `state is AccountLoaded ? (state as AccountLoaded).accounts : const []`
  - `@override Future<void> close()` — cancel subscription, `super.close()`

**Checkpoint**: `AccountCubit` is fully functional. `flutter analyze` must pass.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Wire all Cubits into the app entry point and confirm the full layer compiles cleanly.

- [x] T010 Update `lib/main.dart` — add a `MultiBlocProvider` wrapping the existing `MultiRepositoryProvider` child. Provide all four Cubits via `BlocProvider`, each receiving its dependencies from `context.read<...>()`, and call `..loadAll()` eagerly on creation. Follow the wiring example in `quickstart.md` exactly. The `BudgetCubit` requires both `IBudgetRepository` and `BudgetService` — ensure `BudgetService` is also provided to the `MultiRepositoryProvider` if not already present.

- [x] T011 Run `flutter analyze` from the repo root. Fix every warning and error before marking complete. Common issues to watch for: unused imports, non-exhaustive switch on sealed types, missing `await` on `close()`, `StreamSubscription` declared without `cancel()` in `close()`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: No implementation tasks — data layer already exists
- **User Stories (Phase 3–6)**: All depend on Phase 1 gate passing. Each story is independent — they may be worked in parallel.
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

| Story | Depends on | Can start after |
|-------|-----------|-----------------|
| US1 Transactions (P1) | Data layer (Feature 001) | Phase 1 gate |
| US2 Budgets (P2) | Data layer + BudgetService | Phase 1 gate |
| US3 Categories (P3) | Data layer | Phase 1 gate |
| US4 Accounts (P4) | Data layer | Phase 1 gate |

All four user stories are fully independent — none depends on another.

### Within Each User Story

- State file (T00X) must complete before the Cubit file (T00X+1) in the same story
- The Cubit file imports and extends its state hierarchy

---

## Parallel Opportunities

```
After T001 (gate check):

Parallel group A — all state files (independent files):
  T002 [US1] transaction_state.dart
  T004 [US2] budget_state.dart
  T006 [US3] category_state.dart
  T008 [US4] account_state.dart

After T002 → T003 [US1] transaction_cubit.dart
After T004 → T005 [US2] budget_cubit.dart
After T006 → T007 [US3] category_cubit.dart
After T008 → T009 [US4] account_cubit.dart

Parallel group B — all cubit files (once their own state file is done):
  T003, T005, T007, T009 can run in parallel

After all cubits → T010 main.dart wiring → T011 flutter analyze
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. T001 — gate check
2. T002 — `transaction_state.dart`
3. T003 — `transaction_cubit.dart`
4. T010 (partial) — wire only `TransactionCubit` in main.dart
5. T011 — analyze
6. **STOP and VALIDATE**: `TransactionCubit` loads, filters, and handles errors

### Incremental Delivery

1. US1 (T002–T003) → analyze → validate → MVP complete
2. US2 (T004–T005) → analyze → validate → Budgets with consumption
3. US3 (T006–T007) → analyze → validate → Category management
4. US4 (T008–T009) → analyze → validate → Account management
5. T010–T011 → full app wired and clean

---

## Notes

- `[P]` tasks = different files, no shared dependencies, safe to run in parallel
- `[Story]` label maps each task to its user story for traceability
- No test tasks generated — tests were not requested in the feature specification
- All Cubits use sealed state classes (Dart 3.x) — exhaustive pattern matching is enforced at compile time
- Stream subscriptions **must** be cancelled in `close()` — every Cubit must override `close()`
- `flutter analyze` must pass after each story phase checkpoint before proceeding
