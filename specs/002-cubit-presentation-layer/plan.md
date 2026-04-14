# Implementation Plan: Budget App MVP - Cubit Presentation Layer

**Branch**: `002-cubit-presentation-layer` | **Date**: 2026-04-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/002-cubit-presentation-layer/spec.md`

## Summary

Implement four Cubits (Transaction, Budget, Category, Account) that wrap the existing data layer repository interfaces and expose clean, reactive UI state. Each Cubit manages loading/loaded/error state transitions, subscribes to the repository's `watchAll()` stream for real-time updates, and translates typed repository exceptions into human-readable error messages. The `TransactionCubit` additionally supports in-memory filtering; the `BudgetCubit` includes consumption data sourced from `BudgetService`.

## Technical Context

**Language/Version**: Dart 3.x (SDK ^3.11.4)
**Primary Dependencies**: flutter_bloc ^9.x (Cubit), equatable ^2.x, existing data layer interfaces
**Storage**: Drift (SQLite via existing data layer — Cubits access storage only through repository interfaces)
**Testing**: flutter_test + bloc_test ^10.x + mocktail ^1.x
**Target Platform**: iOS + Android (Flutter mobile app)
**Project Type**: mobile-app
**Performance Goals**: State transition completes within 300ms for lists up to 10,000 items; UI receives stream update within one event loop tick
**Constraints**: Cubits depend only on repository interfaces, never on Drift directly; stream subscriptions cancelled in `close()`
**Scale/Scope**: 4 Cubits, 4 state class hierarchies, in-memory filtering for transactions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| State management: Cubit (not Provider/Riverpod/GetX) | PASS | Spec explicitly requires Cubit |
| UI decoupled from business logic | PASS | Cubits contain zero UI code; this feature is state-management only |
| Avoid `dynamic` typing | PASS | All state fields use strict model types from Feature 001 |
| Immutability / Equatable | PASS | FR-007 requires Equatable on all state classes |
| Feature-first folder structure (`lib/features/`) | PASS | Cubits placed under `lib/features/` per constitution |
| No complexity violations | PASS | Standard Cubit pattern, no architectural novelty |

## Project Structure

### Documentation (this feature)

```text
specs/002-cubit-presentation-layer/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── transactions/
│   │   ├── cubit/
│   │   │   ├── transaction_cubit.dart
│   │   │   └── transaction_state.dart
│   ├── budgets/
│   │   ├── cubit/
│   │   │   ├── budget_cubit.dart
│   │   │   └── budget_state.dart
│   ├── categories/
│   │   ├── cubit/
│   │   │   ├── category_cubit.dart
│   │   │   └── category_state.dart
│   └── accounts/
│       ├── cubit/
│       │   ├── account_cubit.dart
│       │   └── account_state.dart
├── data/                # Existing — not modified by this feature
│   ├── models/
│   ├── repositories/
│   └── services/
└── main.dart            # Updated to provide Cubits via BlocProvider

test/
├── features/
│   ├── transactions/
│   │   └── cubit/
│   │       └── transaction_cubit_test.dart
│   ├── budgets/
│   │   └── cubit/
│   │       └── budget_cubit_test.dart
│   ├── categories/
│   │   └── cubit/
│   │       └── category_cubit_test.dart
│   └── accounts/
│       └── cubit/
│           └── account_cubit_test.dart
```

**Structure Decision**: Feature-first layout under `lib/features/` per constitution. Each feature directory contains a `cubit/` subdirectory with the Cubit class and its state class. Tests mirror the source tree under `test/features/`.
