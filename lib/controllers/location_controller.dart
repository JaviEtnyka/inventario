// controllers/location_controller.dart
import '../models/location.dart';
import '../services/api_service.dart';

class LocationController {
  // Obtener todas las ubicaciones
  Future<List<Location>> getAllLocations() async {
    try {
      // Para pruebas iniciales, puedes usar datos estáticos
      // return _getTestLocations();
      
      // Para conectar con la API real
      return await ApiService.getLocations();
    } catch (e) {
      print('Error en getAllLocations: $e');
      throw Exception('Error al obtener las ubicaciones: $e');
    }
  }
  
  // Datos de prueba para desarrollo inicial
  List<Location> _getTestLocations() {
    return [
      Location(id: 1, name: 'Sala de estar', description: 'Área principal'),
      Location(id: 2, name: 'Dormitorio', description: 'Habitación principal'),
      Location(id: 3, name: 'Cocina', description: 'Área de preparación de alimentos'),
      Location(id: 4, name: 'Oficina', description: 'Espacio de trabajo'),
      Location(id: 5, name: 'Garaje', description: 'Almacenamiento y vehículos'),
    ];
  }
}