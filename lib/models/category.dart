// models/category.dart
class Category {
  final int? id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  
  Category({
    this.id,
    required this.name,
    this.description = '',
    this.createdAt,
    this.updatedAt,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}