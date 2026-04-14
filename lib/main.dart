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
import 'data/services/budget_service.dart';
import 'data/services/seed_service.dart';
import 'features/accounts/cubit/account_cubit.dart';
import 'features/budgets/cubit/budget_cubit.dart';
import 'features/categories/cubit/category_cubit.dart';
import 'features/transactions/cubit/transaction_cubit.dart';

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
        RepositoryProvider<BudgetService>(
          create: (context) => BudgetService(
            context.read<ITransactionRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TransactionCubit(
              context.read<ITransactionRepository>(),
            )..loadAll(),
          ),
          BlocProvider(
            create: (context) => BudgetCubit(
              context.read<IBudgetRepository>(),
              context.read<BudgetService>(),
            )..loadAll(),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(
              context.read<ICategoryRepository>(),
            )..loadAll(),
          ),
          BlocProvider(
            create: (context) => AccountCubit(
              context.read<IAccountRepository>(),
            )..loadAll(),
          ),
        ],
        child: const BudgetApp(),
      ),
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
