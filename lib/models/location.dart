// models/location.dart
class Location {
  final int? id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  
  Location({
    this.id,
    required this.name,
    this.description = '',
    this.createdAt,
    this.updatedAt,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
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