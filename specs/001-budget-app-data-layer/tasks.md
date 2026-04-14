# Tasks: Budget App MVP - Data Layer

**Input**: Design documents from `/specs/001-budget-app-data-layer/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓

**Tests**: Not included (not explicitly requested in spec.md). See `quickstart.md` for manual verification steps.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Install all new dependencies and scaffold the directory structure before any implementation begins.

- [x] T001 Update `pubspec.yaml` with all data layer dependencies: `flutter_bloc ^9.0.0`, `equatable ^2.0.7`, `drift ^2.23.1`, `sqlite3_flutter_libs ^0.5.29`, `path_provider ^2.1.5`, `uuid ^4.5.1` (dependencies) and `drift_dev ^2.23.1`, `build_runner ^2.4.13`, `bloc_test ^10.0.0`, `mocktail ^1.0.4` (dev_dependencies) per `specs/001-budget-app-data-layer/research.md`
- [x] T002 Run `flutter pub get` to install all new dependencies
- [x] T003 [P] Create source directory structure: `lib/data/models/`, `lib/data/repositories/impl/`, `lib/data/services/`, `lib/data/local/tables/`, `lib/data/local/daos/` per `specs/001-budget-app-data-layer/plan.md`
- [x] T004 [P] Create test directory structure: `test/data/models/`, `test/data/repositories/`, `test/data/services/`

**Checkpoint**: Dependencies installed, directory skeleton in place — Foundational phase can begin.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core building blocks that ALL user stories depend on — enumerations, exception types, Equatable models, Drift table definitions, and the AppDatabase root. No user story work can begin until this phase is complete.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T005 [P] Create all domain enumerations (`TransactionType`, `CategoryType`, `AccountType`, `BudgetPeriod`) in `lib/data/models/enums.dart` per `specs/001-budget-app-data-layer/data-model.md`
- [x] T006 [P] Create all repository exception types (`EntityNotFoundException`, `DuplicateEntityException`, `ProtectedEntityException`, `EntityInUseException`, `ValidationException`) in `lib/data/repositories/repository_exceptions.dart` per `specs/001-budget-app-data-layer/contracts/repository-interfaces.md`
- [x] T007 [P] Create `TransactionModel` as an immutable `Equatable` class with all fields, `copyWith`, and `props` in `lib/data/models/transaction_model.dart` per `specs/001-budget-app-data-layer/data-model.md`
- [x] T008 [P] Create `BudgetModel` as an immutable `Equatable` class with all fields, `copyWith`, and `props` in `lib/data/models/budget_model.dart` per `specs/001-budget-app-data-layer/data-model.md`
- [x] T009 [P] Create `CategoryModel` as an immutable `Equatable` class with all fields, `copyWith`, and `props` in `lib/data/models/category_model.dart` per `specs/001-budget-app-data-layer/data-model.md`
- [x] T010 [P] Create `AccountModel` as an immutable `Equatable` class with all fields, `copyWith`, and `props` in `lib/data/models/account_model.dart` per `specs/001-budget-app-data-layer/data-model.md`
- [x] T011 [P] Create `TransactionsTable` Drift table (columns: id TEXT PK, amount REAL, type TEXT, date INTEGER, category_id TEXT FK, account_id TEXT FK, description TEXT nullable, created_at INTEGER, updated_at INTEGER) in `lib/data/local/tables/transactions_table.dart`
- [x] T012 [P] Create `BudgetsTable` Drift table (columns: id TEXT PK, category_id TEXT FK, limit_amount REAL, period_type TEXT, period_start INTEGER, period_end INTEGER nullable, created_at INTEGER, updated_at INTEGER) in `lib/data/local/tables/budgets_table.dart`
- [x] T013 [P] Create `CategoriesTable` Drift table (columns: id TEXT PK, name TEXT UNIQUE, type TEXT, is_default INTEGER, created_at INTEGER) in `lib/data/local/tables/categories_table.dart`
- [x] T014 [P] Create `AccountsTable` Drift table (columns: id TEXT PK, name TEXT, type TEXT, starting_balance REAL, created_at INTEGER, updated_at INTEGER) in `lib/data/local/tables/accounts_table.dart`
- [x] T015 Create `AppDatabase` class annotated with `@DriftDatabase` referencing all 4 tables, with `openConnection()` factory for production (path_provider) and `NativeDatabase.memory()` for tests, in `lib/data/local/app_database.dart` (depends on T011–T014)
- [x] T016 Run `dart run build_runner build --delete-conflicting-outputs` to generate Drift code (`app_database.g.dart`) — must succeed with zero errors (depends on T015)

**Checkpoint**: All models, tables, and the AppDatabase are compiled and generated — user story phases can now begin.

---

## Phase 3: User Story 1 - Record Financial Transactions (Priority: P1) 🎯 MVP

**Goal**: Provide the complete CRUD + filtering contract for transactions so the app can record, retrieve, and query all financial activity.

**Independent Test**: Record a transaction (amount, type, date, category FK, account FK), call `getAll()`, verify 1 result with all fields intact. Call `getByDateRange()` with matching/non-matching ranges, verify correct results. See `specs/001-budget-app-data-layer/quickstart.md` for the smoke-test snippet.

- [x] T017 [P] [US1] Create `ITransactionRepository` abstract class with all method signatures and doc comments in `lib/data/repositories/i_transaction_repository.dart` per `specs/001-budget-app-data-layer/contracts/repository-interfaces.md`
- [x] T018 [US1] Create `TransactionDao` as a Drift DAO with: `getAll()` (order by date DESC), `getById()`, `getByDateRange()` (inclusive), `getByCategory()`, `getByAccount()`, `insertTransaction()`, `updateTransaction()`, `deleteTransaction()`, `watchAll()` stream in `lib/data/local/daos/transaction_dao.dart` (depends on T016)
- [x] T019 [US1] Create `DriftTransactionRepository` implementing `ITransactionRepository`, delegating to `TransactionDao`, converting between Drift row types and `TransactionModel`, throwing typed exceptions from `repository_exceptions.dart` on violations in `lib/data/repositories/impl/drift_transaction_repository.dart` (depends on T017, T018)
- [x] T020 [US1] Register `TransactionDao` in `AppDatabase` via `@DriftAccessor` and re-run `build_runner` in `lib/data/local/app_database.dart` (depends on T019)

**Checkpoint**: `ITransactionRepository` contract is fulfilled — User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Manage Budget Limits (Priority: P2)

**Goal**: Provide the CRUD contract for budgets and a service that computes consumption (amount spent vs. limit) for any category+period combination.

**Independent Test**: Create a budget (category FK, limitAmount=500, monthly period). Create transactions totaling 450 under the same category. Call `BudgetService.getConsumption()` and verify `amountSpent=450`, `budgetRemaining=50`, `isOverBudget=false`.

- [x] T021 [P] [US2] Create `IBudgetRepository` abstract class with all method signatures including `getActiveForCategory(categoryId, date)` in `lib/data/repositories/i_budget_repository.dart` per `specs/001-budget-app-data-layer/contracts/repository-interfaces.md`
- [x] T022 [P] [US2] Create `SummaryModel` and `CategorySummaryModel` as immutable `Equatable` classes with all computed fields and `props` in `lib/data/models/summary_model.dart` per `specs/001-budget-app-data-layer/data-model.md`
- [x] T023 [US2] Create `BudgetDao` as a Drift DAO with: `getAll()`, `getById()`, `getByCategory()`, `getActiveForCategory()` (date range overlap query), `insertBudget()`, `updateBudget()`, `deleteBudget()`, `watchAll()` in `lib/data/local/daos/budget_dao.dart` (depends on T016)
- [x] T024 [US2] Create `DriftBudgetRepository` implementing `IBudgetRepository`, delegating to `BudgetDao`, with `ValidationException` on `limitAmount <= 0` or invalid custom period, in `lib/data/repositories/impl/drift_budget_repository.dart` (depends on T021, T023)
- [x] T025 [US2] Register `BudgetDao` in `AppDatabase` and re-run `build_runner` in `lib/data/local/app_database.dart` (depends on T024)
- [x] T026 [US2] Implement `BudgetService` with `getConsumption(categoryId, budget)` that sums matching transactions for the period and returns a `CategorySummaryModel` with `amountSpent`, `budgetRemaining`, and `isOverBudget` in `lib/data/services/budget_service.dart` (depends on T017, T021)

**Checkpoint**: `IBudgetRepository` + `BudgetService` are functional — User Story 2 is fully testable independently.

---

## Phase 5: User Story 3 - Organize with Categories (Priority: P3)

**Goal**: Provide full category CRUD with protection rules (no delete of default or in-use categories), plus automatic seeding of 10 default categories on first launch.

**Independent Test**: Call `SeedService.seedDefaultCategories()` twice (idempotency check), verify exactly 10 categories exist. Create a custom category, verify it appears in `getAll()`. Attempt to delete a default category, verify `ProtectedEntityException` is thrown.

- [x] T027 [P] [US3] Create `ICategoryRepository` abstract class with all method signatures including `getDefaults()`, `getByType()`, and `delete()` (with exception contract) in `lib/data/repositories/i_category_repository.dart` per `specs/001-budget-app-data-layer/contracts/repository-interfaces.md`
- [x] T028 [US3] Create `CategoryDao` as a Drift DAO with: `getAll()`, `getById()`, `getDefaults()` (where isDefault=1), `getByType()`, `insertCategory()`, `updateCategory()`, `deleteCategory()` (check referenced transactions before delete), `watchAll()` in `lib/data/local/daos/category_dao.dart` (depends on T016)
- [x] T029 [US3] Create `DriftCategoryRepository` implementing `ICategoryRepository`, throwing `ProtectedEntityException` on delete of a default category and `EntityInUseException` if any transaction references it, in `lib/data/repositories/impl/drift_category_repository.dart` (depends on T027, T028)
- [x] T030 [US3] Register `CategoryDao` in `AppDatabase` and re-run `build_runner` in `lib/data/local/app_database.dart` (depends on T029)
- [x] T031 [US3] Implement `SeedService.seedDefaultCategories()` with 10 hardcoded default categories (6 expense: Food & Dining, Transport, Housing, Entertainment, Health, Shopping; 4 income: Salary, Freelance, Investment, Other Income) — idempotent via `getDefaults()` check — in `lib/data/services/seed_service.dart` (depends on T027)

**Checkpoint**: `ICategoryRepository` + `SeedService` are functional — User Story 3 is fully testable independently.

---

## Phase 6: User Story 4 - Manage Multiple Accounts (Priority: P4)

**Goal**: Provide full account CRUD with starting balance support and protection against deleting accounts that still have transactions.

**Independent Test**: Create two accounts with different starting balances. Record transactions against each. Call `getByAccount()` for each account, verify correct transaction isolation. Attempt to delete an account with transactions, verify `EntityInUseException` is thrown.

- [x] T032 [P] [US4] Create `IAccountRepository` abstract class with all method signatures and `delete()` exception contract in `lib/data/repositories/i_account_repository.dart` per `specs/001-budget-app-data-layer/contracts/repository-interfaces.md`
- [x] T033 [US4] Create `AccountDao` as a Drift DAO with: `getAll()`, `getById()`, `insertAccount()`, `updateAccount()`, `deleteAccount()` (check referenced transactions before delete), `watchAll()` in `lib/data/local/daos/account_dao.dart` (depends on T016)
- [x] T034 [US4] Create `DriftAccountRepository` implementing `IAccountRepository`, throwing `EntityInUseException` on delete of an account with transactions and `ValidationException` on empty name, in `lib/data/repositories/impl/drift_account_repository.dart` (depends on T032, T033)
- [x] T035 [US4] Register `AccountDao` in `AppDatabase` and re-run `build_runner` in `lib/data/local/app_database.dart` (depends on T034)

**Checkpoint**: `IAccountRepository` is functional — User Story 4 is fully testable independently.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Complete the summary service, wire the data layer into the Flutter app entry point, and ensure the project is clean.

- [x] T036 [P] Implement `SummaryService.getSummary(from, to)` that aggregates transactions into `SummaryModel` (total income, total expenses, net balance, per-category `CategorySummaryModel` list with budget consumption via `BudgetService`) in `lib/data/services/summary_service.dart` (depends on T017, T021, T027, T036 resolves all repository dependencies)
- [x] T037 [P] Update `lib/main.dart` with `WidgetsFlutterBinding.ensureInitialized()`, `AppDatabase` instantiation, `SeedService.seedDefaultCategories()` call, and `MultiRepositoryProvider` wrapping the app with all 4 concrete repositories per `specs/001-budget-app-data-layer/quickstart.md`
- [x] T038 [P] Update `CLAUDE.md` commands section with: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter test`, `flutter analyze`
- [x] T039 Run `flutter analyze` and resolve all warnings and info-level diagnostics to zero in the `lib/data/` tree

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (T001–T004) — **BLOCKS all user stories**
- **User Stories (Phases 3–6)**: All depend on Foundational phase completion (T016 must pass)
  - Phases 3–6 may proceed in parallel once Phase 2 is complete
  - Or sequentially P1 → P2 → P3 → P4 for a solo developer
- **Polish (Phase 7)**: Depends on all desired user story phases being complete

### User Story Dependencies

- **US1 (P1)**: No dependency on other stories — start immediately after Phase 2
- **US2 (P2)**: No dependency on US1, US3, or US4 — start in parallel with US1
- **US3 (P3)**: No dependency on US1 or US2 — start in parallel
- **US4 (P4)**: No dependency on US1, US2, or US3 — start in parallel
- All 4 user stories depend only on the Foundational phase

### Within Each User Story

- Abstract interface ([US1] T017, [US2] T021, [US3] T027, [US4] T032) can be created in parallel with models
- DAO depends on Drift codegen (T016)
- Concrete repository depends on its interface + DAO
- AppDatabase registration depends on concrete repository being complete
- Services ([US2] T026, [US3] T031, Polish T036) depend on interfaces (not concrete implementations)

### Parallel Opportunities

- **T005–T010 (models + enums + exceptions)**: All 6 tasks can run fully in parallel
- **T011–T014 (Drift tables)**: All 4 can run fully in parallel
- **T017 + T018 (US1 interface + DAO)**: Can run in parallel (different files, no cross-dependency)
- **T021 + T022 + T023 (US2 interface + model + DAO)**: All 3 can run in parallel
- **T027 + T028 (US3 interface + DAO)**: Can run in parallel
- **T032 + T033 (US4 interface + DAO)**: Can run in parallel
- **T036 + T037 + T038 (Polish)**: All 3 can run in parallel

---

## Parallel Example: Foundational Phase

```
Parallel batch 1 (all at once):
  Task T005: lib/data/models/enums.dart
  Task T006: lib/data/repositories/repository_exceptions.dart
  Task T007: lib/data/models/transaction_model.dart
  Task T008: lib/data/models/budget_model.dart
  Task T009: lib/data/models/category_model.dart
  Task T010: lib/data/models/account_model.dart
  Task T011: lib/data/local/tables/transactions_table.dart
  Task T012: lib/data/local/tables/budgets_table.dart
  Task T013: lib/data/local/tables/categories_table.dart
  Task T014: lib/data/local/tables/accounts_table.dart

Sequential after batch 1:
  Task T015: lib/data/local/app_database.dart
  Task T016: dart run build_runner build (must complete before any DAO)
```

## Parallel Example: User Stories After Phase 2

```
Once T016 (build_runner) is green, all 4 story phases can start simultaneously:
  Developer A → Phase 3: T017, T018, T019, T020 (US1 Transactions)
  Developer B → Phase 4: T021, T022, T023, T024, T025, T026 (US2 Budgets)
  Developer C → Phase 5: T027, T028, T029, T030, T031 (US3 Categories)
  Developer D → Phase 6: T032, T033, T034, T035 (US4 Accounts)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks everything)
3. Complete Phase 3: User Story 1 (Transaction CRUD + filtering)
4. **STOP and VALIDATE**: Use quickstart.md smoke test — record a transaction, retrieve it, filter by date range
5. Demo the data layer with a minimal UI or debug screen

### Incremental Delivery

1. Setup + Foundational → stable base with all models and DB schema
2. + US1 (Transactions) → can record and query all financial activity (MVP!)
3. + US2 (Budgets) → can set spending limits and check consumption
4. + US3 (Categories) → full category management + default seeding
5. + US4 (Accounts) → multi-wallet support
6. + Polish → summary reporting, full wiring, zero warnings

---

## Notes

- `[P]` tasks touch different files with no shared dependencies — safe to implement simultaneously
- `[Story]` label maps each task to its user story for traceability back to `spec.md`
- AppDatabase registration tasks (T020, T025, T030, T035) each require a `build_runner` re-run — batch these if working sequentially to avoid redundant regeneration
- All DAO tasks depend on T016 (first `build_runner` run) completing without errors
- Service tasks (T026, T031, T036) depend on abstract interfaces only — they are testable with mocks before concrete implementations exist
- Total task count: **39 tasks** (T001–T039)
