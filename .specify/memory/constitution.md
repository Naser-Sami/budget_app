 # Project Overview

This is a smart budget management MVP built with Flutter.


# Architecture & State Management

- Use Flutter Bloc (specifically Cubit for simpler states, Bloc for complex event-driven states) for all state management.

- Do not use Provider, Riverpod, or GetX.

- Keep UI components decoupled from business logic. UI files should only contain presentation code and BlocBuilders/BlocListeners.


# Flutter & Dart Best Practices (Adapted from Core Guidelines)

- **Immutability:** Use `const` constructors for Widgets everywhere possible to optimize the rebuild cycle.

- **Pure Build Methods:** Ensure `build()` methods have no side effects. They should only return widgets based on the current state.

- **Composition over Inheritance:** Build complex UIs by composing smaller, reusable stateless widgets rather than subclassing.

- **Formatting:** Strictly adhere to standard `dart format`. Always use trailing commas in Widget trees to ensure readable formatting.

- **Typing:** Avoid `dynamic`. Use strict typing for all variables, method signatures, and return types.


# Code Style

- Use trailing commas for all Flutter widgets to ensure proper formatting.

- Extract highly reusable widgets into a separate `core/widgets` directory.

- Prefer explicit type declarations over `var` or `dynamic`.


# Folder Structure

- /lib/core (for themes, constants, shared widgets)

- /lib/features (feature-first architecture) 