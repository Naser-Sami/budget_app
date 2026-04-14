# Implementation Plan: Budget App MVP - Data Layer

**Branch**: `001-budget-app-data-layer` | **Date**: 2026-04-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-budget-app-data-layer/spec.md`

## Summary

Build the complete data layer for a Flutter budget app MVP: immutable Equatable models for all 5 entities (Transaction, Budget, Category, Account, Summary), abstract repository interfaces as stable contracts, concrete local-storage implementations backed by Drift (type-safe SQLite ORM), and business-logic services for budget consumption, period summaries, and default category seeding. The Bloc/Cubit presentation layer (out of scope here) will depend exclusively on the abstract interfaces.

## Technical Context

**Language/Version**: Dart 3.x (Flutter SDK ^3.11.4, Dart ^3.0)
**Primary Dependencies**: `flutter_bloc ^9.x`, `equatable ^2.x`, `drift ^2.x`, `sqlite3_flutter_libs`, `path_provider`, `uuid ^4.x`, `bloc_test ^10.x`, `mocktail ^1.x`
**Storage**: SQLite via Drift — type-safe relational ORM with DAOs, reactive streams, and in-memory support for testing
**Testing**: `flutter_test`, `bloc_test`, `mocktail`; Drift `NativeDatabase.memory()` for repository integration tests
**Target Platform**: iOS + Android (mobile-first, offline-capable)
**Project Type**: Mobile application (Flutter)
**Performance Goals**: All data operations < 300ms for up to 10,000 transactions (SC-001)
**Constraints**: Offline-only, single user, single currency, no cloud sync in MVP
**Scale/Scope**: Single user, 4 persisted entities + 1 computed entity, target up to 10,000 transactions

## Constitution Check

The project constitution (`.specify/memory/constitution.md`) has not been filled in — it contains only a placeholder template with no defined principles, gates, or constraints. No constitutional rules apply at this time.

**Gate Status**: PASS — proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-budget-app-data-layer/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── repository-interfaces.md   # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks — NOT by /speckit.plan)
```

### Source Code

```text
lib/
├── data/
│   ├── models/
│   │   ├── transaction_model.dart        # Equatable value object
│   │   ├── budget_model.dart
│   │   ├── category_model.dart
│   │   ├── account_model.dart
│   │   └── summary_model.dart            # Computed (not persisted)
│   ├── repositories/
│   │   ├── i_transaction_repository.dart # Abstract interface
│   │   ├── i_budget_repository.dart
│   │   ├── i_category_repository.dart
│   │   ├── i_account_repository.dart
│   │   └── impl/
│   │       ├── drift_transaction_repository.dart
│   │       ├── drift_budget_repository.dart
│   │       ├── drift_category_repository.dart
│   │       └── drift_account_repository.dart
│   ├── services/
│   │   ├── budget_service.dart           # Budget consumption calculations
│   │   ├── summary_service.dart          # Period income/expense summaries
│   │   └── seed_service.dart             # Default category seeding
│   └── local/
│       ├── app_database.dart             # Drift AppDatabase root
│       ├── tables/
│       │   ├── transactions_table.dart
│       │   ├── budgets_table.dart
│       │   ├── categories_table.dart
│       │   └── accounts_table.dart
│       └── daos/
│           ├── transaction_dao.dart
│           ├── budget_dao.dart
│           ├── category_dao.dart
│           └── account_dao.dart

test/
└── data/
    ├── models/
    │   ├── transaction_model_test.dart
    │   ├── budget_model_test.dart
    │   ├── category_model_test.dart
    │   └── account_model_test.dart
    ├── repositories/
    │   ├── transaction_repository_test.dart   # Uses in-memory Drift DB
    │   ├── budget_repository_test.dart
    │   ├── category_repository_test.dart
    │   └── account_repository_test.dart
    └── services/
        ├── budget_service_test.dart
        └── summary_service_test.dart
```

**Structure Decision**: Single Flutter project. All data layer code lives under `lib/data/` with four explicit sub-layers: models (pure value objects), repositories (abstract + concrete), services (business logic), and local (Drift tables + DAOs). This cleanly separates the data access contract from the storage mechanism, satisfying FR-011 and enabling the backend to be swapped independently (SC-007).

## Complexity Tracking

No constitutional violations. No complexity justification required.
