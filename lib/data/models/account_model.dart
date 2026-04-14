import 'package:equatable/equatable.dart';
import 'enums.dart';

class AccountModel extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final double startingBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.startingBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? startingBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      startingBalance: startingBalance ?? this.startingBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values.byName(json['type'] as String),
      startingBalance: (json['startingBalance'] as num).toDouble(),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'startingBalance': startingBalance,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        startingBalance,
        createdAt,
        updatedAt,
      ];
}
