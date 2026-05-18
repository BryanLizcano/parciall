import 'package:parcial/domain/model/category.dart';

abstract interface class CategoryRepository {
  /// HU-15: listado de todas las categorías (endpoint público).
  Future<List<Category>> getAll();
}
