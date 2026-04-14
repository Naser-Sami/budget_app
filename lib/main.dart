import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/local/app_database.dart';
import 'data/repositories/i_account_repository.dart';
import 'data/repositories/i_budget_repository.dart';
import 'data/repositories/i_category_repository.dart';
import 'data/repositories/i_transaction_repository.dart';
import 'data/repositories/impl/drift_account_repository.dart';
import 'data/repositories/impl/drift_budget_repository.dart';
import 'data/repositories/impl/drift_category_repository.dart';
import 'data/repositories/impl/drift_transaction_repository.dart';
import 'data/services/seed_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final categoryRepo = DriftCategoryRepository(db.categoryDao);
  final seedService = SeedService(categoryRepo);
  await seedService.seedDefaultCategories();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ITransactionRepository>(
          create: (_) => DriftTransactionRepository(db.transactionDao),
        ),
        RepositoryProvider<IBudgetRepository>(
          create: (_) => DriftBudgetRepository(db.budgetDao),
        ),
        RepositoryProvider<ICategoryRepository>(
          create: (_) => categoryRepo,
        ),
        RepositoryProvider<IAccountRepository>(
          create: (_) => DriftAccountRepository(db.accountDao),
        ),
      ],
      child: const BudgetApp(),
    ),
  );
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Budget App',
      home: Scaffold(
        body: Center(
          child: Text('Budget App'),
        ),
      ),
    );
  }
}
