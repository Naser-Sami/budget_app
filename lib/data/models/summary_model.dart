import 'package:equatable/equatable.dart';
import 'enums.dart';

class CategorySummaryModel extends Equatable {
  final String categoryId;
  final String categoryName;
  final CategoryType categoryType;
  final double total;
  final double? budgetLimit;
  final double? budgetRemaining;
  final bool isOverBudget;

  const CategorySummaryModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.total,
    this.budgetLimit,
    this.budgetRemaining,
    required this.isOverBudget,
  });

  // Sentinel for copyWith nullable fields
  static const Object _absent = Object();

  CategorySummaryModel copyWith({
    String? categoryId,
    String? categoryName,
    CategoryType? categoryType,
    double? total,
    Object? budgetLimit = _absent,
    Object? budgetRemaining = _absent,
    bool? isOverBudget,
  }) {
    return CategorySummaryModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryType: categoryType ?? this.categoryType,
      total: total ?? this.total,
      budgetLimit: identical(budgetLimit, _absent)
          ? this.budgetLimit
          : budgetLimit as double?,
      budgetRemaining: identical(budgetRemaining, _absent)
          ? this.budgetRemaining
          : budgetRemaining as double?,
      isOverBudget: isOverBudget ?? this.isOverBudget,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryType,
        total,
        budgetLimit,
        budgetRemaining,
        isOverBudget,
      ];
}

class SummaryModel extends Equatable {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
  final List<CategorySummaryModel> categoryBreakdown;

  const SummaryModel({
    required this.periodStart,
    required this.periodEnd,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
    required this.categoryBreakdown,
  });

  SummaryModel copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalIncome,
    double? totalExpenses,
    double? netBalance,
    List<CategorySummaryModel>? categoryBreakdown,
  }) {
    return SummaryModel(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netBalance: netBalance ?? this.netBalance,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
    );
  }

  @override
  List<Object?> get props => [
        periodStart,
        periodEnd,
        totalIncome,
        totalExpenses,
        netBalance,
        categoryBreakdown,
      ];
}
