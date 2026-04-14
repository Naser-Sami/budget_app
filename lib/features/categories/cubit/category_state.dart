import 'package:equatable/equatable.dart';
import '../../../data/models/category_model.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();

  @override
  List<Object?> get props => [];
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();

  @override
  List<Object?> get props => [];
}

final class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

final class CategoryError extends CategoryState {
  final String message;
  final List<CategoryModel> lastKnownCategories;

  const CategoryError({
    required this.message,
    required this.lastKnownCategories,
  });

  @override
  List<Object?> get props => [message, lastKnownCategories];
}
