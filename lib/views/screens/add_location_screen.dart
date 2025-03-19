// controllers/location_controller.dart
import '../../models/location.dart';
import '../../services/api_service.dart';

class LocationController {
  // Obtener todas las ubicaciones
  Future<List<Location>> getAllLocations() async {
    try {
      return await ApiService.getLocations();
    } catch (e) {
      print('Error en getAllLocations: $e');
      throw Exception('Error al obtener las ubicaciones: $e');
    }
  }
  
  // Obtener una ubicación por ID
  Future<Location> getLocation(int id) async {
    try {
      return await ApiService.getLocationById(id);
    } catch (e) {
      print('Error en getLocation: $e');
      throw Exception('Error al obtener la ubicación: $e');
    }
  }
  
  // Crear una nueva ubicación
  Future<int> createLocation(Location location) async {
    try {
      return await ApiService.createLocation(location);
    } catch (e) {
      print('Error en createLocation: $e');
      throw Exception('Error al crear la ubicación: $e');
    }
  }
  
  // Actualizar una ubicación existente
  Future<void> updateLocation(Location location) async {
    try {
      await ApiService.updateLocation(location);
    } catch (e) {
      print('Error en updateLocation: $e');
      throw Exception('Error al actualizar la ubicación: $e');
    }
  }
  
  // Eliminar una ubicación
  Future<void> deleteLocation(int id) async {
    try {
      await ApiService.deleteLocation(id);
    } catch (e) {
      print('Error en deleteLocation: $e');
      throw Exception('Error al eliminar la ubicación: $e');
    }
  }
  
  // Buscar ubicaciones por nombre
  Future<List<Location>> searchLocationsByName(String query) async {
    try {
      final locations = await getAllLocations();
      if (query.isEmpty) return locations;
      
      query = query.toLowerCase();
      return locations.where((location) {
        return location.name.toLowerCase().contains(query) ||
               location.description.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      print('Error en searchLocationsByName: $e');
      throw Exception('Error al buscar ubicaciones: $e');
    }
  }
}