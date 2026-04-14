import 'package:uuid/uuid.dart';

import '../models/category_model.dart';
import '../models/enums.dart';
import '../repositories/i_category_repository.dart';

class SeedService {
  final ICategoryRepository _categoryRepository;

  SeedService(this._categoryRepository);

  /// Seeds default categories if none exist. Idempotent.
  Future<void> seedDefaultCategories() async {
    final existingDefaults = await _categoryRepository.getDefaults();
    if (existingDefaults.isNotEmpty) {
      return;
    }

    const uuid = Uuid();
    final now = DateTime.now();

    final categoriesToSeed = [
      // Expense Categories
      _createCategory(uuid, 'Food & Dining', CategoryType.expense, now),
      _createCategory(uuid, 'Transport', CategoryType.expense, now),
      _createCategory(uuid, 'Housing', CategoryType.expense, now),
      _createCategory(uuid, 'Entertainment', CategoryType.expense, now),
      _createCategory(uuid, 'Health', CategoryType.expense, now),
      _createCategory(uuid, 'Shopping', CategoryType.expense, now),

      // Income Categories
      _createCategory(uuid, 'Salary', CategoryType.income, now),
      _createCategory(uuid, 'Freelance', CategoryType.income, now),
      _createCategory(uuid, 'Investment', CategoryType.income, now),
      _createCategory(uuid, 'Other Income', CategoryType.income, now),
    ];

    for (final category in categoriesToSeed) {
      await _categoryRepository.create(category);
    }
  }

  CategoryModel _createCategory(
    Uuid uuid,
    String name,
    CategoryType type,
    DateTime createdAt,
  ) {
    return CategoryModel(
      id: uuid.v4(),
      name: name,
      type: type,
      isDefault: true,
      createdAt: createdAt,
    );
  }
}
