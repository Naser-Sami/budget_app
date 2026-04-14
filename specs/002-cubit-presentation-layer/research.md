# Research: Budget App MVP - Cubit Presentation Layer

**Feature**: `002-cubit-presentation-layer`
**Date**: 2026-04-14

---

## Decision 1: Cubit vs Bloc

**Decision**: Use Cubit for all four entities.
**Rationale**: The spec's operations (load, create, update, delete, filter) are direct method calls with no complex event chains or side-effect compositions that would require Bloc's event stream. Cubit is the simpler model, preferred by the constitution for straightforward state cases.
**Alternatives considered**: Full `Bloc` with typed events — rejected because it adds boilerplate with no benefit for these CRUD operations.

---

## Decision 2: State class hierarchy — sealed classes vs abstract + subclasses

**Decision**: Use `sealed` classes (Dart 3.x) for each state hierarchy.
**Rationale**: Dart 3 sealed classes enforce exhaustive pattern matching at compile time, which is critical for `BlocBuilder`s — forgetting to handle an error state becomes a compile error, not a runtime gap. Equatable is extended by each concrete subclass.
**Alternatives considered**: Abstract class with `is` type checks — rejected because non-exhaustive checks are not compiler-enforced.

---

## Decision 3: Stream subscription management

**Decision**: Subscribe to `watchAll()` in the Cubit constructor; cancel in `close()` via `StreamSubscription.cancel()`.
**Rationale**: Spec FR-006 and Assumptions explicitly require this. Subscribing in the constructor means the stream is active for the full lifetime of the Cubit. Cancelling in `close()` prevents memory leaks after the Cubit is disposed.
**Alternatives considered**: Subscribing on first `loadAll()` call — rejected because it creates a race condition between the initial fetch and the first stream emission.

---

## Decision 4: Error state retains last known list

**Decision**: Each error state carries both an error message (`String`) and the last known list (`List<T>`).
**Rationale**: FR-005 and SC-006 require the UI to display the error alongside existing data, and to restore the loaded state without a new repository call when the error is dismissed. Retaining the list in error state makes this trivial — the Cubit simply emits `LoadedState(items: errorState.items)` on dismiss.
**Alternatives considered**: Separate `lastItems` field on Cubit class — rejected because it breaks state immutability and complicates Equatable comparison.

---

## Decision 5: In-memory filtering for TransactionCubit

**Decision**: Store the full unfiltered list in the loaded state; expose an `activeFilters` object. The Cubit computes the filtered view and emits it as part of `TransactionLoaded`.
**Rationale**: FR-009 prohibits additional repository calls for filtering. Keeping the full list in state means filters can be applied and removed without touching the database.
**Alternatives considered**: Storing only the filtered list and re-fetching on filter change — rejected by FR-009.

---

## Decision 6: BudgetCubit consumption data source

**Decision**: `BudgetCubit` calls `BudgetService.getConsumption()` for each loaded budget after fetching the list from the repository.
**Rationale**: FR-010 requires consumption data (amount spent, remaining, over-budget flag) in the loaded state. `BudgetService` already encapsulates this calculation. The service takes `ITransactionRepository` — consistent with FR-008 (no Drift dependency in Cubits).
**Alternatives considered**: Computing consumption inline in the Cubit — rejected because it duplicates `BudgetService` logic and violates separation of concerns.

---

## Decision 7: Typed exception → error message mapping

**Decision**: Catch `Exception` in each Cubit operation, inspect the runtime type, and produce a plain-English string. The mapping lives in each Cubit (not a shared utility) to keep error messages contextual.
**Rationale**: FR-004 requires typed exception translation; SC-003 requires 100% coverage. Keeping messages per-Cubit allows entity-specific wording (e.g., "Cannot delete a category that is in use by transactions").
**Alternatives considered**: Shared `ExceptionMapper` utility — acceptable but adds indirection for only 5 exception types. Deferred to a polish phase.

---

## Decision 8: BlocProvider registration in main.dart

**Decision**: Add four `BlocProvider<XCubit>` entries inside the existing `MultiRepositoryProvider` in `main.dart`. Cubits receive repositories via constructor injection.
**Rationale**: The spec Assumptions note the composition root already exists. Cubit constructors accept repository interfaces, satisfying FR-008.
**Alternatives considered**: Lazy BlocProvider — acceptable default but explicit is clearer for MVP.
