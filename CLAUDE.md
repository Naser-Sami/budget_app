# budget_app Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-14

## Active Technologies

- Dart 3.x (Flutter SDK ^3.11.4, Dart ^3.0) + `flutter_bloc ^9.x`, `equatable ^2.x`, `drift ^2.x`, `sqlite3_flutter_libs`, `path_provider`, `uuid ^4.x`, `bloc_test ^10.x`, `mocktail ^1.x` (001-budget-app-data-layer)

## Project Structure

```text
src/
tests/
```

## Commands

```bash
# Install dependencies
flutter pub get

# Regenerate Drift database code after changing tables or DAOs
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run data layer tests only
flutter test test/data/

# Static analysis
flutter analyze
```

## Code Style

Dart 3.x (Flutter SDK ^3.11.4, Dart ^3.0): Follow standard conventions

## Recent Changes

- 001-budget-app-data-layer: Added Dart 3.x (Flutter SDK ^3.11.4, Dart ^3.0) + `flutter_bloc ^9.x`, `equatable ^2.x`, `drift ^2.x`, `sqlite3_flutter_libs`, `path_provider`, `uuid ^4.x`, `bloc_test ^10.x`, `mocktail ^1.x`

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
