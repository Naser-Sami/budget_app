import 'package:equatable/equatable.dart';
import 'enums.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final CategoryType type;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    CategoryType? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values.byName(json['type'] as String),
      isDefault: json['isDefault'] as bool,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'isDefault': isDefault,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isDefault,
        createdAt,
      ];
}
