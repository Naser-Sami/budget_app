import 'package:drift/drift.dart';

import '../../models/category_model.dart';
import '../../models/enums.dart';
import '../i_category_repository.dart';
import '../repository_exceptions.dart';
import '../../local/app_database.dart';
import '../../local/daos/category_dao.dart';

class DriftCategoryRepository implements ICategoryRepository {
  final CategoryDao _dao;

  DriftCategoryRepository(this._dao);

  CategoryModel _toModel(CategoriesTableData row) {
    return CategoryModel(
      id: row.id,
      name: row.name,
      type: CategoryType.values.byName(row.type),
      isDefault: row.isDefault,
      createdAt: row.createdAt,
    );
  }

  CategoriesTableCompanion _toCompanion(CategoryModel model) {
    return CategoriesTableCompanion(
      id: Value(model.id),
      name: Value(model.name),
      type: Value(model.type.name),
      isDefault: Value(model.isDefault),
      createdAt: Value(model.createdAt),
    );
  }

  @override
  Future<List<CategoryModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<CategoryModel>> getDefaults() async {
    final rows = await _dao.getDefaults();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<CategoryModel>> getByType(CategoryType type) async {
    final rows = await _dao.getByType(type.name);
    return rows.map(_toModel).toList();
  }

  @override
  Future<void> create(CategoryModel category) async {
    if (category.name.trim().isEmpty) {
      throw ValidationException('Category name cannot be empty.');
    }

    try {
      await _dao.insertCategory(_toCompanion(category));
    } on Exception catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('unique') || message.contains('constraint failed')) {
        throw DuplicateEntityException('Category name "${category.name}" already exists.');
      }
      rethrow;
    }
  }

  @override
  Future<void> update(CategoryModel category) async {
    if (category.name.trim().isEmpty) {
      throw ValidationException('Category name cannot be empty.');
    }

    late final int rowsUpdated;
    try {
      rowsUpdated = await _dao.updateCategory(_toCompanion(category));
    } on Exception catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('unique') || message.contains('constraint failed')) {
        throw DuplicateEntityException('Category name "${category.name}" already exists.');
      }
      rethrow;
    }

    if (rowsUpdated == 0) {
      throw EntityNotFoundException('Category with ID ${category.id} not found.');
    }
  }

  @override
  Future<void> delete(String id) async {
    final row = await _dao.getById(id);
    if (row == null) return;

    if (row.isDefault) {
      throw ProtectedEntityException(
          'Category "${row.name}" is a system default and cannot be deleted.');
    }

    if (await _dao.isCategoryInUse(id)) {
      throw EntityInUseException('Category is referenced by existing transactions.');
    }

    await _dao.deleteCategory(id);
  }

  @override
  Stream<List<CategoryModel>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toModel).toList());
  }
}
