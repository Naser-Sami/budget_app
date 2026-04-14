# Feature Specification: Budget App MVP - Cubit Presentation Layer

**Feature Branch**: `002-cubit-presentation-layer`
**Created**: 2026-04-14
**Status**: Draft
**Input**: User description: "Build the Bloc/Cubit presentation layer for the budget app MVP. Implement Cubits and state classes for Transactions, Budgets, Categories, and Accounts. Use the existing data layer repositories and services. Flutter, Bloc/Cubit, and Equatable."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View and Manage Transactions (Priority: P1)

A user opens the app and sees their complete list of transactions. They can add a new transaction, edit an existing one, and delete one they no longer need. The screen reflects the latest state at all times without requiring a manual refresh.

**Why this priority**: Transactions are the core of the app — all other features depend on this data existing. A working transaction screen is the minimum viable demonstration of the full stack (data layer + state management + UI).

**Independent Test**: Can be fully tested by observing the Cubit emit a loading state, then a loaded state containing the transaction list. Adding a transaction triggers a new loaded state with the item appended. Deleting triggers a new loaded state with it removed. An invalid transaction (e.g. amount of zero) emits an error state.

**Acceptance Scenarios**:

1. **Given** the app launches, **When** the transaction Cubit initialises, **Then** it emits a loading state followed by a loaded state containing all persisted transactions, newest first.
2. **Given** the loaded state, **When** the user submits a valid new transaction, **Then** the Cubit emits a new loaded state with the transaction included and no error.
3. **Given** the loaded state, **When** the user submits a transaction with amount zero or negative, **Then** the Cubit emits an error state with a human-readable message and the list remains unchanged.
4. **Given** the loaded state, **When** the user deletes a transaction, **Then** the Cubit emits a new loaded state with that transaction removed.
5. **Given** the loaded state, **When** the user updates a transaction, **Then** the Cubit emits a new loaded state reflecting the change.

---

### User Story 2 - View and Manage Budgets (Priority: P2)

A user can set a monthly spending limit for a category and see how much of that budget has been consumed. They can create new budgets, edit limits, and delete budgets they no longer need.

**Why this priority**: Budget management is the defining feature of the app. Once transactions exist, budget state gives users the feedback loop that makes the app useful.

**Independent Test**: Can be fully tested by observing the budget Cubit emit a loaded state containing budget models with consumption data. Creating a budget emits a new loaded state with it included. Submitting an invalid limit (≤ 0) emits an error state.

**Acceptance Scenarios**:

1. **Given** the app launches, **When** the budget Cubit initialises, **Then** it emits a loaded state with all budgets and their current consumption figures.
2. **Given** the loaded state, **When** the user creates a valid budget, **Then** the Cubit emits a new loaded state with the budget included.
3. **Given** the loaded state, **When** the user submits a budget with a limit of zero or negative, **Then** the Cubit emits an error state with a human-readable message.
4. **Given** the loaded state, **When** the user deletes a budget, **Then** the Cubit emits a new loaded state with that budget removed.

---

### User Story 3 - Manage Categories (Priority: P3)

A user can view all categories, create custom ones, and delete categories they created. System default categories are always visible but cannot be deleted.

**Why this priority**: Categories are shared by transactions and budgets. Managing them through state ensures the UI stays consistent when a new category is added or an unused custom one is removed.

**Independent Test**: Can be fully tested by observing the category Cubit emit a loaded state with the seeded default categories. Adding a custom category emits a new loaded state with it included. Attempting to delete a default category emits an error state; deleting a custom one emits a new loaded state with it removed.

**Acceptance Scenarios**:

1. **Given** the app launches, **When** the category Cubit initialises, **Then** it emits a loaded state containing all categories (defaults + any user-created ones).
2. **Given** the loaded state, **When** the user creates a category with a valid name, **Then** the Cubit emits a new loaded state with the category included.
3. **Given** the loaded state, **When** the user attempts to delete a default category, **Then** the Cubit emits an error state with a clear message and the list is unchanged.
4. **Given** the loaded state, **When** the user deletes a custom category, **Then** the Cubit emits a new loaded state with it removed.
5. **Given** the loaded state, **When** the user submits an empty category name, **Then** the Cubit emits an error state.

---

### User Story 4 - Manage Accounts (Priority: P4)

A user can view all their financial accounts, add new ones with a starting balance, edit them, and delete accounts that have no transactions.

**Why this priority**: Accounts provide the context for every transaction. Multi-account support is lower priority than the other stories but completes the full data management surface.

**Independent Test**: Can be fully tested by observing the account Cubit emit a loaded state with existing accounts. Adding an account emits a new loaded state with it included. Attempting to delete an account that has transactions emits an error state.

**Acceptance Scenarios**:

1. **Given** the app launches, **When** the account Cubit initialises, **Then** it emits a loaded state containing all accounts.
2. **Given** the loaded state, **When** the user adds a valid account, **Then** the Cubit emits a new loaded state with it included.
3. **Given** the loaded state, **When** the user attempts to delete an account that has transactions, **Then** the Cubit emits an error state with a clear message.
4. **Given** the loaded state, **When** the user deletes an account with no transactions, **Then** the Cubit emits a new loaded state with it removed.
5. **Given** the loaded state, **When** the user submits an account with an empty name, **Then** the Cubit emits an error state.

---

### Edge Cases

- What happens when a repository call fails (e.g. database error)? The Cubit must emit an error state rather than crashing.
- What happens if a Cubit receives a second action while a previous async operation is still in progress?
- What happens when the stream from `watchAll()` emits while the Cubit is in an error state?
- What happens if the user tries to add a transaction referencing a category or account that no longer exists?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each entity (Transaction, Budget, Category, Account) MUST have a dedicated Cubit that manages its own loading, loaded, and error states independently.
- **FR-002**: Each Cubit MUST expose an initial load method that fetches all relevant data and transitions from loading to loaded state.
- **FR-003**: Each Cubit MUST support create, update, and delete operations that optimistically or reactively update the state after the repository call completes.
- **FR-004**: Each Cubit MUST emit an error state with a human-readable message when a repository throws a typed exception (`ValidationException`, `EntityNotFoundException`, `DuplicateEntityException`, `ProtectedEntityException`, `EntityInUseException`).
- **FR-005**: After an error, the Cubit MUST retain the last known good list so the UI can display both the error message and the existing data simultaneously.
- **FR-006**: Each Cubit MUST subscribe to the repository's `watchAll()` stream so the UI reacts to data changes without manual refresh.
- **FR-007**: All state classes MUST extend `Equatable` so Bloc's change detection prevents unnecessary UI rebuilds.
- **FR-008**: Cubits MUST depend only on repository interfaces, never on concrete implementations or Drift directly.
- **FR-009**: The `TransactionCubit` MUST support filtering the displayed list by date range, category, and account without making additional repository calls (filter applied to in-memory loaded list).
- **FR-010**: The `BudgetCubit` MUST include consumption data (amount spent, remaining, over-budget flag) in its loaded state, sourced from `BudgetService`.

### Key Entities

- **TransactionState**: Represents the UI state for the transaction list — variants: initial, loading, loaded (list + active filters), error (message + last known list).
- **BudgetState**: Represents the UI state for the budget list — variants: initial, loading, loaded (list with consumption), error (message + last known list).
- **CategoryState**: Represents the UI state for the category list — variants: initial, loading, loaded (list), error (message + last known list).
- **AccountState**: Represents the UI state for the account list — variants: initial, loading, loaded (list), error (message + last known list).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every Cubit state transition completes within 300 milliseconds for a list of up to 10,000 items.
- **SC-002**: An error in one Cubit (e.g. failed delete) does not affect the state of any other Cubit.
- **SC-003**: 100% of typed repository exceptions are translated to human-readable error state messages — no unhandled exceptions reach the UI.
- **SC-004**: The UI receives a state update within one event loop tick of a `watchAll()` stream emission.
- **SC-005**: Filtering transactions by date range, category, or account produces correct results with 100% accuracy against the loaded list.
- **SC-006**: Removing error state (e.g. user dismisses the error) restores the last known loaded state without a new repository call.

## Assumptions

- The data layer (repositories, services, models) from `specs/001-budget-app-data-layer` is complete and stable — Cubits depend on its interfaces.
- This feature covers state management only — no UI widgets or screens are in scope. Cubits provide state; screens will be built in a subsequent feature.
- A single `BlocProvider` / `MultiRepositoryProvider` composition root already exists in `main.dart` from the data layer feature; Cubits will be added to it.
- Stream subscriptions opened in Cubit constructors (for `watchAll()`) MUST be cancelled in `close()` to avoid memory leaks.
- The `TransactionCubit` will use `BudgetService` only when needed for budget display; `SummaryService` is out of scope for this feature.
- Error messages exposed in state are plain English strings — localisation is out of scope for MVP.
- The implementation uses Flutter with Bloc/Cubit, Equatable, and the existing data layer — these are implementation constraints for the planning stage.
