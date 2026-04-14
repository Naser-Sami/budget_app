# Quickstart: Budget App MVP - Data Layer

**Branch**: `001-budget-app-data-layer` | **Date**: 2026-04-14

---

## Prerequisites

- Flutter SDK ≥ 3.11.4 installed and on PATH
- A device or simulator running iOS 13+ or Android API 21+
- `dart` and `flutter` CLI tools available

---

## Step 1: Add Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.0.0
  equatable: ^2.0.7
  drift: ^2.23.1
  sqlite3_flutter_libs: ^0.5.29
  path_provider: ^2.1.5
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.23.1
  build_runner: ^2.4.13
  bloc_test: ^10.0.0
  mocktail: ^1.0.4
  flutter_lints: ^6.0.0
```

Then run:
```bash
flutter pub get
```

---

## Step 2: Generate Drift Code

After implementing the Drift tables (see `lib/data/local/`), run the code generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Re-run this command whenever table definitions or DAO queries change.

---

## Step 3: Initialize the Database

In `lib/main.dart`, create the `AppDatabase` and seed default categories before launching the app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final categoryRepo = DriftCategoryRepository(db);
  final seedService = SeedService(categoryRepo);
  await seedService.seedDefaultCategories();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ITransactionRepository>(
          create: (_) => DriftTransactionRepository(db),
        ),
        RepositoryProvider<IBudgetRepository>(
          create: (_) => DriftBudgetRepository(db),
        ),
        RepositoryProvider<ICategoryRepository>(
          create: (_) => categoryRepo,
        ),
        RepositoryProvider<IAccountRepository>(
          create: (_) => DriftAccountRepository(db),
        ),
      ],
      child: const BudgetApp(),
    ),
  );
}
```

---

## Step 4: Run Tests

### All data layer tests
```bash
flutter test test/data/
```

### Model unit tests only
```bash
flutter test test/data/models/
```

### Repository integration tests (uses in-memory DB)
```bash
flutter test test/data/repositories/
```

### Service unit tests (uses mocked repositories)
```bash
flutter test test/data/services/
```

---

## Step 5: Verify Data Layer Works

A minimal smoke test — add this to your integration test or a temporary debug screen:

```dart
final transactionRepo = context.read<ITransactionRepository>();
final categoryRepo = context.read<ICategoryRepository>();

final categories = await categoryRepo.getAll();
print('Seeded ${categories.length} categories');  // Should be 10

await transactionRepo.create(TransactionModel(
  id: const Uuid().v4(),
  amount: 25.50,
  type: TransactionType.expense,
  date: DateTime.now(),
  categoryId: categories.first.id,
  accountId: 'your-account-id',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
));

final all = await transactionRepo.getAll();
print('Transactions: ${all.length}');  // Should be 1
```

---

## Project Layout After Implementation

```
lib/data/
├── models/           # 5 Equatable model files
├── repositories/     # 4 abstract interfaces + 4 Drift implementations
├── services/         # budget_service, summary_service, seed_service
└── local/
    ├── app_database.dart
    ├── tables/       # 4 Drift table definitions
    └── daos/         # 4 Drift DAOs

test/data/
├── models/           # Equality and copyWith tests
├── repositories/     # CRUD + filter query tests (in-memory DB)
└── services/         # Calculation tests (mocked repos)
```

---

## Common Issues

| Problem | Solution |
|---------|----------|
| `build_runner` fails with conflicts | Run with `--delete-conflicting-outputs` flag |
| `sqlite3` missing on Linux desktop | Add `sqlite3` to your system packages; not needed for mobile |
| Tests fail with "no such table" | Ensure the in-memory DB uses `NativeDatabase.memory()` and the same `AppDatabase` schema |
| Foreign key violations on delete | Check `EntityInUseException` handling — delete child records first or use cascade (not default) |
