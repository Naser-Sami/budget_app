# Data Model: Budget App MVP - Data Layer

**Branch**: `001-budget-app-data-layer` | **Date**: 2026-04-14
**Source**: `spec.md` — Key Entities section + Functional Requirements

---

## Enumerations

### `TransactionType`
```
income | expense
```

### `CategoryType`
```
income | expense
```

### `AccountType`
```
cash | bank | card | other
```

### `BudgetPeriod`
```
monthly | weekly | custom
```

---

## Entity: TransactionModel

**Represents**: A single financial event (money in or out).

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `String` | Yes | UUID v4, generated on creation |
| `amount` | `double` | Yes | Must be > 0 |
| `type` | `TransactionType` | Yes | `income` or `expense` |
| `date` | `DateTime` | Yes | Date/time of the transaction |
| `categoryId` | `String` | Yes | FK → CategoryModel.id |
| `accountId` | `String` | Yes | FK → AccountModel.id |
| `description` | `String?` | No | Optional user note |
| `createdAt` | `DateTime` | Yes | Set on creation, never updated |
| `updatedAt` | `DateTime` | Yes | Set on creation, updated on every write |

**Validation rules**:
- `amount` must be > 0
- `date` must not be null
- `categoryId` must reference an existing Category
- `accountId` must reference an existing Account

**Relationships**:
- Many-to-one → `CategoryModel` (via `categoryId`)
- Many-to-one → `AccountModel` (via `accountId`)

---

## Entity: BudgetModel

**Represents**: A spending target for a category within a defined time period.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `String` | Yes | UUID v4 |
| `categoryId` | `String` | Yes | FK → CategoryModel.id |
| `limitAmount` | `double` | Yes | Must be > 0 |
| `periodType` | `BudgetPeriod` | Yes | `monthly`, `weekly`, or `custom` |
| `periodStart` | `DateTime` | Yes | Start of the budget period |
| `periodEnd` | `DateTime?` | No | Required only for `custom` period type |
| `createdAt` | `DateTime` | Yes | Set on creation |
| `updatedAt` | `DateTime` | Yes | Updated on every write |

**Validation rules**:
- `limitAmount` must be > 0
- `periodEnd` is required when `periodType == custom`
- `periodEnd` must be after `periodStart` if set
- Only one active budget per category per period (enforced at service layer)

**Relationships**:
- Many-to-one → `CategoryModel` (via `categoryId`)

**State transitions**:
- Active → Expired: when current date passes `periodEnd` (for custom) or end of calendar period (for monthly/weekly)

---

## Entity: CategoryModel

**Represents**: A named classification for transactions and budgets.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `String` | Yes | UUID v4 |
| `name` | `String` | Yes | Non-empty, unique across categories |
| `type` | `CategoryType` | Yes | `income` or `expense` |
| `isDefault` | `bool` | Yes | `true` for system-seeded categories |
| `createdAt` | `DateTime` | Yes | Set on creation |

**Validation rules**:
- `name` must be non-empty
- `name` must be unique within the user's categories
- `isDefault` categories may not be deleted (enforced at service/repository layer)

**Relationships**:
- One-to-many → `TransactionModel` (a category has many transactions)
- One-to-many → `BudgetModel` (a category can have many budgets)

---

## Entity: AccountModel

**Represents**: A financial account or wallet (e.g., cash, bank account, credit card).

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `String` | Yes | UUID v4 |
| `name` | `String` | Yes | Non-empty, user-defined label |
| `type` | `AccountType` | Yes | `cash`, `bank`, `card`, or `other` |
| `startingBalance` | `double` | Yes | Default: `0.0`. Can be negative (debt) |
| `createdAt` | `DateTime` | Yes | Set on creation |
| `updatedAt` | `DateTime` | Yes | Updated on every write |

**Validation rules**:
- `name` must be non-empty
- Computed `currentBalance = startingBalance + sum(income transactions) − sum(expense transactions)`

**Relationships**:
- One-to-many → `TransactionModel` (an account has many transactions)

---

## Entity: SummaryModel *(Computed — Not Persisted)*

**Represents**: An aggregated financial view for a given date range. Produced by `SummaryService`, never stored in the database.

| Field | Type | Notes |
|-------|------|-------|
| `periodStart` | `DateTime` | Inclusive start of the range |
| `periodEnd` | `DateTime` | Inclusive end of the range |
| `totalIncome` | `double` | Sum of all income transactions in period |
| `totalExpenses` | `double` | Sum of all expense transactions in period |
| `netBalance` | `double` | `totalIncome − totalExpenses` |
| `categoryBreakdown` | `List<CategorySummaryModel>` | Per-category totals with optional budget info |

---

## Entity: CategorySummaryModel *(Nested in SummaryModel — Not Persisted)*

**Represents**: Per-category spending within a summary period.

| Field | Type | Notes |
|-------|------|-------|
| `categoryId` | `String` | Reference to the category |
| `categoryName` | `String` | Denormalized for display |
| `categoryType` | `CategoryType` | `income` or `expense` |
| `total` | `double` | Sum of transactions for this category in period |
| `budgetLimit` | `double?` | `null` if no budget defined for this category+period |
| `budgetRemaining` | `double?` | `budgetLimit − total`; `null` if no budget |
| `isOverBudget` | `bool` | `true` if `total > budgetLimit` |

---

## Entity Relationships Overview

```
AccountModel ──< TransactionModel >── CategoryModel ──< BudgetModel
                                           │
                                    (seeded by SeedService)
                                           │
                              CategorySummaryModel (computed)
                                           │
                                     SummaryModel (computed)
```

---

## Drift Table Mapping

| Model | Drift Table | Primary Key | Foreign Keys |
|-------|------------|-------------|--------------|
| `TransactionModel` | `Transactions` | `id TEXT` | `category_id → Categories.id`, `account_id → Accounts.id` |
| `BudgetModel` | `Budgets` | `id TEXT` | `category_id → Categories.id` |
| `CategoryModel` | `Categories` | `id TEXT` | — |
| `AccountModel` | `Accounts` | `id TEXT` | — |

All tables include `created_at INTEGER` (Unix ms) and `updated_at INTEGER` (where applicable). All foreign key constraints use `RESTRICT` on delete for Transactions and `SET NULL` is not applicable — deleting a category with transactions must be prevented at the repository layer (FR-010).
