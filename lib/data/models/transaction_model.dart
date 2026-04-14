import 'package:equatable/equatable.dart';
import 'enums.dart';

class TransactionModel extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String categoryId;
  final String accountId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.categoryId,
    required this.accountId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // Sentinel used so copyWith(description: null) can explicitly clear the field.
  static const Object _absent = Object();

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? categoryId,
    String? accountId,
    Object? description = _absent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      description: identical(description, _absent)
          ? this.description
          : description as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      description: json['description'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'date': date.millisecondsSinceEpoch,
        'categoryId': categoryId,
        'accountId': accountId,
        if (description != null) 'description': description,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        date,
        categoryId,
        accountId,
        description,
        createdAt,
        updatedAt,
      ];
}
