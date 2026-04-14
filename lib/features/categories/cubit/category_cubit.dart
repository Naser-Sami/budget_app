import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/category_model.dart';
import '../../../data/repositories/i_category_repository.dart';
import '../../../data/repositories/repository_exceptions.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ICategoryRepository _repository;
  late final StreamSubscription<List<CategoryModel>> _subscription;

  CategoryCubit(this._repository) : super(const CategoryInitial()) {
    _subscription = _repository.watchAll().listen((categories) {
      emit(CategoryLoaded(categories: categories));
    });
  }

  Future<void> loadAll() async {
    emit(const CategoryLoading());
    try {
      final result = await _repository.getAll();
      emit(CategoryLoaded(categories: result));
    } on Exception catch (e) {
      emit(CategoryError(
        message: _mapError(e),
        lastKnownCategories: const [],
      ));
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      if (category.name.trim().isEmpty) {
        throw ValidationException('Category name cannot be empty.');
      }
      await _repository.create(category);
    } on Exception catch (e) {
      emit(CategoryError(
        message: _mapError(e),
        lastKnownCategories: _currentCategories,
      ));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.delete(id);
    } on Exception catch (e) {
      emit(CategoryError(
        message: _mapError(e),
        lastKnownCategories: _currentCategories,
      ));
    }
  }

  void dismissError() {
    if (state is CategoryError) {
      final errorState = state as CategoryError;
      emit(CategoryLoaded(categories: errorState.lastKnownCategories));
    }
  }

  String _mapError(Exception e) {
    if (e is ValidationException) return e.message;
    if (e is ProtectedEntityException) return 'Default categories cannot be deleted.';
    if (e is EntityInUseException) {
      return 'This category is used by existing transactions and cannot be deleted.';
    }
    if (e is EntityNotFoundException) return 'Category not found.';
    if (e is DuplicateEntityException) {
      return 'A category with this name already exists.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  List<CategoryModel> get _currentCategories {
    final s = state;
    if (s is CategoryLoaded) return s.categories;
    return const [];
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
