import '../models/category_model.dart';
import '../models/enums.dart';
import 'repository_exceptions.dart';

abstract class ICategoryRepository {
  /// Returns all categories.
  Future<List<CategoryModel>> getAll();

  /// Returns a single category by ID, or null if not found.
  Future<CategoryModel?> getById(String id);

  /// Returns only system-seeded (default) categories.
  Future<List<CategoryModel>> getDefaults();

  /// Returns categories of the given [type] (income or expense).
  Future<List<CategoryModel>> getByType(CategoryType type);

  /// Persists a new category.
  ///
  /// Throws [ValidationException] if `category.name` is empty.
  /// Throws [DuplicateEntityException] if the name already exists.
  Future<void> create(CategoryModel category);

  /// Updates an existing category.
  ///
  /// Throws [EntityNotFoundException] if ID not found.
  /// Throws [ValidationException] if `category.name` is empty.
  /// Throws [DuplicateEntityException] if the name already exists.
  Future<void> update(CategoryModel category);

  /// Deletes a category by ID. No-op if not found and not protected.
  ///
  /// Throws [ProtectedEntityException] if category is a system default.
  /// Throws [EntityInUseException] if any transaction references this category.
  Future<void> delete(String id);

  /// Reactive stream — emits the full category list whenever any category changes.
  Stream<List<CategoryModel>> watchAll();
}
