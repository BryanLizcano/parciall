import '../../domain/model/category.dart';

/// DTO para mapear la respuesta de GET /categories (HU-15)
class CategoryDto {
  final int id;
  final String name;

  const CategoryDto({required this.id, required this.name});

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
    id: json['id'] as int,
    name: json['name'] as String,
  );

  Category toDomain() => Category(id: id, name: name);
}