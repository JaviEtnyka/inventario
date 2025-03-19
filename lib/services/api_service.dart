// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../models/location.dart';

class ApiService {
  // ========== ITEMS ==========
  
  /// Obtiene todos los items del inventario
  static Future<List<Item>> getItems() async {
    try {
      print('Obteniendo items desde: ${ApiConfig.readItems}');
      final response = await http.get(Uri.parse(ApiConfig.readItems));
      
      print('Respuesta HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (!decodedData.containsKey('records')) {
          print('La respuesta no contiene la clave "records"');
          return [];
        }
        
        final List<dynamic> itemsJson = decodedData['records'];
        print('Items encontrados: ${itemsJson.length}');
        
        return itemsJson.map((json) => Item.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron items (404)');
        return [];
      } else {
        throw Exception('Error al obtener los items: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en getItems: $e');
      // Para desarrollo, devuelve una lista vacía en lugar de lanzar otra excepción
      return [];
    }
  }
  
  /// Obtiene un item por su ID
  static Future<Item> getItemById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.readOneItem}?id=$id'));
      
      if (response.statusCode == 200) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getItemById: $e');
      rethrow;
    }
  }
  
  /// Crea un nuevo item
  static Future<int> createItem(Item item) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createItem),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson())
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('id')) {
          return int.parse(data['id'].toString());
        } else {
          return 0; // Si no hay ID, devolvemos 0 temporalmente
        }
      } else {
        throw Exception('Error al crear el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createItem: $e');
      rethrow;
    }
  }
  
  /// Actualiza un item existente
  static Future<void> updateItem(Item item) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateItem),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson())
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateItem: $e');
      rethrow;
    }
  }
  
  /// Elimina un item por su ID
  static Future<void> deleteItem(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteItem),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteItem: $e');
      rethrow;
    }
  }
  
  // ========== CATEGORÍAS ==========
  
  /// Obtiene todas las categorías
  static Future<List<Category>> getCategories() async {
    try {
      print('Obteniendo categorías desde: ${ApiConfig.readCategories}');
      final response = await http.get(Uri.parse(ApiConfig.readCategories));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (!decodedData.containsKey('records')) {
          print('La respuesta no contiene la clave "records"');
          return [];
        }
        
        final List<dynamic> categoriesJson = decodedData['records'];
        print('Categorías encontradas: ${categoriesJson.length}');
        
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron categorías (404)');
        return [];
      } else {
        throw Exception('Error al obtener las categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en getCategories: $e');
      return [];
    }
  }
  
  /// Obtiene una categoría por su ID
  static Future<Category> getCategoryById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.readOneCategory}?id=$id'));
      
      if (response.statusCode == 200) {
        return Category.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener la categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getCategoryById: $e');
      rethrow;
    }
  }
  
  /// Crea una nueva categoría
  static Future<int> createCategory(Category category) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createCategory),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(category.toJson())
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('id')) {
          return int.parse(data['id'].toString());
        } else {
          return 0;
        }
      } else {
        throw Exception('Error al crear la categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createCategory: $e');
      rethrow;
    }
  }
  
  /// Actualiza una categoría existente
  static Future<void> updateCategory(Category category) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateCategory),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(category.toJson())
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateCategory: $e');
      rethrow;
    }
  }
  
  /// Elimina una categoría por su ID
  static Future<void> deleteCategory(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteCategory),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteCategory: $e');
      rethrow;
    }
  }
  
  // ========== UBICACIONES ==========
  
  /// Obtiene todas las ubicaciones
  static Future<List<Location>> getLocations() async {
    try {
      print('Obteniendo ubicaciones desde: ${ApiConfig.readLocations}');
      final response = await http.get(Uri.parse(ApiConfig.readLocations));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        if (!decodedData.containsKey('records')) {
          print('La respuesta no contiene la clave "records"');
          return [];
        }
        
        final List<dynamic> locationsJson = decodedData['records'];
        print('Ubicaciones encontradas: ${locationsJson.length}');
        
        return locationsJson.map((json) => Location.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('No se encontraron ubicaciones (404)');
        return [];
      } else {
        throw Exception('Error al obtener las ubicaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en getLocations: $e');
      return [];
    }
  }
  
  /// Obtiene una ubicación por su ID
  static Future<Location> getLocationById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.readOneLocation}?id=$id'));
      
      if (response.statusCode == 200) {
        return Location.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getLocationById: $e');
      rethrow;
    }
  }
  
  /// Crea una nueva ubicación
  static Future<int> createLocation(Location location) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson())
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('id')) {
          return int.parse(data['id'].toString());
        } else {
          return 0;
        }
      } else {
        throw Exception('Error al crear la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createLocation: $e');
      rethrow;
    }
  }
  
  /// Actualiza una ubicación existente
  static Future<void> updateLocation(Location location) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson())
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateLocation: $e');
      rethrow;
    }
  }
  
  /// Elimina una ubicación por su ID
  static Future<void> deleteLocation(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteLocation),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la ubicación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteLocation: $e');
      rethrow;
    }
  }
  
  // ========== IMÁGENES ==========
  
  /// Sube una sola imagen al servidor
  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadImage),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['imageUrl'];
      } else {
        throw Exception('Error al subir la imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en uploadImage: $e');
      rethrow;
    }
  }
  
  /// Sube múltiples imágenes al servidor
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadMultipleImages),
      );
      
      for (var file in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]',
          file.path,
          filename: file.path.split('/').last,
        ));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return List<String>.from(responseData['imageUrls']);
      } else {
        throw Exception('Error al subir las imágenes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en uploadMultipleImages: $e');
      // En caso de error, devolver lista vacía para desarrollo
      return [];
    }
  }
  
  // ========== UTILIDADES ==========
  
  /// Comprueba si la API está disponible
  static Future<bool> checkApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error al comprobar la conexión con la API: $e');
      return false;
    }
  }
}