import 'package:equatable/equatable.dart';
import 'enums.dart';

class BudgetModel extends Equatable {
  final String id;
  final String categoryId;
  final double limitAmount;
  final BudgetPeriod periodType;
  final DateTime periodStart;
  final DateTime? periodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.periodType,
    required this.periodStart,
    this.periodEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  // Sentinel used so copyWith(periodEnd: null) can explicitly clear the field.
  static const Object _absent = Object();

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    BudgetPeriod? periodType,
    DateTime? periodStart,
    Object? periodEnd = _absent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      periodType: periodType ?? this.periodType,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: identical(periodEnd, _absent)
          ? this.periodEnd
          : periodEnd as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      periodType: BudgetPeriod.values.byName(json['periodType'] as String),
      periodStart:
          DateTime.fromMillisecondsSinceEpoch(json['periodStart'] as int),
      periodEnd: json['periodEnd'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['periodEnd'] as int),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'periodType': periodType.name,
        'periodStart': periodStart.millisecondsSinceEpoch,
        if (periodEnd != null) 'periodEnd': periodEnd!.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [
        id,
        categoryId,
        limitAmount,
        periodType,
        periodStart,
        periodEnd,
        createdAt,
        updatedAt,
      ];
}
