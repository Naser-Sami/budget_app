import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable, TransactionsTable])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<CategoriesTableData>> getAll() {
    return select(categoriesTable).get();
  }

  Future<CategoriesTableData?> getById(String id) {
    return (select(categoriesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<CategoriesTableData>> getDefaults() {
    return (select(categoriesTable)..where((t) => t.isDefault.equals(true))).get();
  }

  Future<List<CategoriesTableData>> getByType(String type) {
    return (select(categoriesTable)..where((t) => t.type.equals(type))).get();
  }

  Future<void> insertCategory(CategoriesTableCompanion category) {
    return into(categoriesTable).insert(category);
  }

  Future<int> updateCategory(CategoriesTableCompanion category) {
    return (update(categoriesTable)..where((t) => t.id.equals(category.id.value)))
        .write(category);
  }

  Future<void> deleteCategory(String id) {
    return (delete(categoriesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> isCategoryInUse(String id) async {
    final query = select(transactionsTable)..where((t) => t.categoryId.equals(id))..limit(1);
    final match = await query.getSingleOrNull();
    return match != null;
  }

  Stream<List<CategoriesTableData>> watchAll() {
    return select(categoriesTable).watch();
  }
}
