# Research: Budget App MVP - Data Layer

**Branch**: `001-budget-app-data-layer` | **Date**: 2026-04-14
**Purpose**: Resolve all technical unknowns before Phase 1 design

---

## Decision 1: Local Storage Library

**Decision**: Use **Drift** (formerly `moor`) as the local storage layer.

**Rationale**:
- The budget app requires relational queries: filter transactions by date range, category, and account (FR-007); compute aggregated totals and budget consumption (FR-008, FR-009). Drift provides type-safe SQL with compile-time query validation.
- Drift's DAO (Data Access Object) pattern maps cleanly to the repository pattern — each repository delegates to a DAO.
- Drift supports reactive `Stream<List<T>>` queries out of the box, which pairs naturally with Bloc/Cubit `StreamSubscription`.
- Drift's `NativeDatabase.memory()` enables true repository integration tests without any filesystem setup — a first-class testing story.
- Drift enforces referential integrity via foreign keys, directly satisfying FR-010 (category deletion consistency).

**Alternatives Considered**:

| Library | Verdict | Reason Rejected |
|---------|---------|-----------------|
| sqflite | No | Requires raw SQL strings — error-prone, no type safety, tedious mapping boilerplate |
| Hive | No | Key-value NoSQL: excellent performance but cannot express the relational queries and aggregations this app needs |
| Isar | Strong alternative | Excellent performance and query API, but Drift is more mature for relational schemas with joins; Isar can be adopted later if performance warrants it |
| ObjectBox | No | Commercial licensing implications; overkill for MVP |

---

## Decision 2: Model Design — Equatable Value Objects

**Decision**: All models are **immutable Equatable value objects** with a `copyWith` method. No code generation (no `freezed`) for MVP.

**Rationale**:
- `Equatable` from the `equatable` package provides structural equality (`==` and `hashCode`) with minimal boilerplate — critical for Bloc state comparison.
- Immutable models prevent accidental mutation in Cubit state. `copyWith` enables ergonomic state updates.
- Skipping `freezed` keeps the dependency footprint small and avoids a build runner requirement for MVP. `freezed` can be added in a future refactor if the model count grows.
- Models are pure Dart — no Drift annotations. They are independent of the storage layer, satisfying FR-011 and SC-007.

**Pattern**:
```dart
class TransactionModel extends Equatable {
  final String id;
  final double amount;
  // ... other fields

  const TransactionModel({required this.id, required this.amount, ...});

  TransactionModel copyWith({String? id, double? amount, ...}) => ...;

  @override
  List<Object?> get props => [id, amount, ...];
}
```

---

## Decision 3: Repository Pattern Structure

**Decision**: Each entity gets an **abstract interface** (Dart abstract class) and a **Drift-backed concrete implementation**. Cubits depend only on the interface.

**Rationale**:
- Abstractions allow Cubits to be tested with `mocktail` mocks without a real database.
- Concrete implementations are testable independently using an in-memory Drift database.
- Satisfies FR-011 (stable data access contract) and SC-007 (backend swappability).

**Interface contract pattern**:
```dart
abstract class ITransactionRepository {
  Future<List<TransactionModel>> getAll();
  Future<TransactionModel?> getById(String id);
  Future<List<TransactionModel>> getByDateRange(DateTime from, DateTime to);
  Future<List<TransactionModel>> getByCategory(String categoryId);
  Future<List<TransactionModel>> getByAccount(String accountId);
  Future<void> create(TransactionModel transaction);
  Future<void> update(TransactionModel transaction);
  Future<void> delete(String id);
  Stream<List<TransactionModel>> watchAll();
}
```

**Dependency injection**: Pass concrete repository implementations into Cubits at the composition root (e.g., `MultiRepositoryProvider` in `main.dart`). No service locator needed for MVP.

---

## Decision 4: Services Layer Responsibilities

**Decision**: Three services cover all business logic that spans multiple repositories.

| Service | Responsibility |
|---------|---------------|
| `BudgetService` | Given a budget and a list of transactions for the same category+period, compute: `amountSpent`, `remaining`, `isOverBudget` |
| `SummaryService` | Given a date range, aggregate transactions into `SummaryModel`: total income, total expenses, net balance, per-category breakdown with budget consumption |
| `SeedService` | On first launch, populate `ICategoryRepository` with default income and expense categories |

Services take repository interfaces as constructor parameters — they are pure business logic and have no Drift dependency.

---

## Decision 5: Testing Strategy

**Decision**: Three-tier test strategy.

| Tier | What is tested | Tool |
|------|---------------|------|
| Unit: Models | Equatable equality, `copyWith`, field validation | `flutter_test` |
| Integration: Repositories | All CRUD + filter queries against a real schema | `drift` in-memory DB + `flutter_test` |
| Unit: Services | Calculation correctness with mocked repositories | `mocktail` + `flutter_test` |

No `bloc_test` in scope for this feature — Bloc/Cubit layer is out of scope. `bloc_test` is listed in dependencies for the next feature phase.

---

## Decision 6: UUID Generation

**Decision**: Use the `uuid` package (`Uuid().v4()`) to generate entity IDs in the repository `create` methods. IDs are `String` type (UUID v4).

**Rationale**: Simple, globally unique, no DB auto-increment coordination needed. Works offline. Drift stores them as `TEXT`.

---

## Decision 7: Default Categories

**Decision**: `SeedService` ships with **10 default categories** covering common income and expense types, seeded on first launch via `ICategoryRepository`.

**Default expense categories**: Food & Dining, Transport, Housing, Entertainment, Health, Shopping
**Default income categories**: Salary, Freelance, Investment, Other Income

Seed is idempotent: checks `ICategoryRepository.getDefaults()` before inserting.

---

## Packages to Add to pubspec.yaml

```yaml
dependencies:
  flutter_bloc: ^9.0.0
  equatable: ^2.0.7
  drift: ^2.23.1
  sqlite3_flutter_libs: ^0.5.29
  path_provider: ^2.1.5
  uuid: ^4.5.1

dev_dependencies:
  drift_dev: ^2.23.1
  build_runner: ^2.4.13
  bloc_test: ^10.0.0
  mocktail: ^1.0.4
```
