import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../controllers/item_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/location_controller.dart';
import 'excel_export_service.dart';

class DataService {
  // Controladores
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  final ExcelExportService _excelExportService = ExcelExportService();
  
  // Exportar inventario a CSV
  Future<String?> exportInventoryToCsv() async {
    try {
      // Solicitar permisos de almacenamiento si es necesario y no estamos en web
      if (!kIsWeb && Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            return null;
          }
        }
      }
      
      // Obtener datos
      final items = await _itemController.getAllItems();
      
      // Crear contenido CSV
      List<List<dynamic>> csvData = [];
      
      // Cabecera
      csvData.add([
        'ID', 'Nombre', 'Descripción', 'Valor', 
        'Categoría', 'Ubicación', 'Fecha de compra',
        'Fecha de registro', 'Última actualización'
      ]);
      
      // Datos
      for (var item in items) {
        csvData.add([
          item.id,
          item.name,
          item.description,
          item.value,
          item.categoryName,
          item.locationName,
          item.purchaseDate ?? '',
          item.dateAdded ?? '',
          item.lastUpdated ?? ''
        ]);
      }
      
      // Convertir a string CSV
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Si estamos en web, no podemos guardar archivos de la misma manera
      if (kIsWeb) {
        // Para web, podríamos implementar una descarga a través de dart:html
        // Por ahora, devolvemos un indicador especial para manejar el caso en la UI
        print('CSV generado en web. La descarga debe manejarse diferente.');
        return 'web-export';
      } else {
        // Guardar archivo en dispositivos móviles/escritorio
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('$path/inventario_$timestamp.csv');
        await file.writeAsString(csv);
        
        // Compartir archivo
        await Share.shareFiles([file.path], text: 'Inventario Doméstico');
        
        return file.path;
      }
    } catch (e) {
      print('Error al exportar a CSV: $e');
      return null;
    }
  }
  
  // Exportar inventario a JSON
  Future<String?> exportInventoryToJson() async {
    try {
      // Solicitar permisos de almacenamiento si es necesario y no estamos en web
      if (!kIsWeb && Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            return null;
          }
        }
      }
      
      // Obtener datos
      final items = await _itemController.getAllItems();
      final categories = await _categoryController.getAllCategories();
      final locations = await _locationController.getAllLocations();
      
      // Crear estructura de datos JSON
      final Map<String, dynamic> jsonData = {
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'value': item.value,
          'category_id': item.categoryId,
          'location_id': item.locationId,
          'image_urls': item.imageUrls,
          'purchase_date': item.purchaseDate,
          'date_added': item.dateAdded,
          'last_updated': item.lastUpdated,
        }).toList(),
        'categories': categories.map((category) => {
          'id': category.id,
          'name': category.name,
          'description': category.description,
        }).toList(),
        'locations': locations.map((location) => {
          'id': location.id,
          'name': location.name,
          'description': location.description,
        }).toList(),
      };
      
      // Convertir a string JSON
      String jsonString = jsonEncode(jsonData);
      
      // Si estamos en web, no podemos guardar archivos de la misma manera
      if (kIsWeb) {
        // Para web, podríamos implementar una descarga a través de dart:html
        print('JSON generado en web. La descarga debe manejarse diferente.');
        return 'web-export';
      } else {
        // Guardar archivo en dispositivos móviles/escritorio
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('$path/inventario_$timestamp.json');
        await file.writeAsString(jsonString);
        
        // Compartir archivo
        await Share.shareFiles([file.path], text: 'Inventario Doméstico');
        
        return file.path;
      }
    } catch (e) {
      print('Error al exportar a JSON: $e');
      return null;
    }
  }
  
  // Exportar inventario a Excel
  Future<String?> exportInventoryToExcel() async {
    try {
      // Verificar si estamos en web
      if (kIsWeb) {
        print('Exportación a Excel en web no implementada completamente');
        return 'web-export';
      }
      
      // Utilizar el servicio de Excel para exportar
      final filePath = await _excelExportService.exportInventoryToExcel();
      
      // Si se exportó correctamente, compartir el archivo
      if (filePath != null) {
        await _excelExportService.shareExcelFile(filePath);
      }
      
      return filePath;
    } catch (e) {
      print('Error al exportar a Excel: $e');
      return null;
    }
  }
  
  // Importar inventario desde archivo JSON
  Future<bool> importInventoryFromJson() async {
    try {
      // Seleccionar archivo - FilePicker funciona tanto en web como en dispositivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        String jsonString;
        
        // La forma de leer el archivo difiere entre plataformas
        if (kIsWeb) {
          // En web, los bytes están disponibles directamente
          if (result.files.single.bytes != null) {
            jsonString = utf8.decode(result.files.single.bytes!);
          } else {
            throw Exception('No se pudieron leer los bytes del archivo');
          }
        } else {
          // En móvil/escritorio, leemos del path
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }
        
        // Decodificar JSON para validarlo
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        
        // TODO: Implementar la lógica para guardar los datos en la base de datos
        // Aquí procesarías los datos y los guardarías usando tus controladores
        print('Datos JSON importados correctamente. Procesamiento pendiente.');
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error al importar desde JSON: $e');
      return false;
    }
  }
  
  // Realizar copia de seguridad
  Future<bool> createBackup() async {
    // En una implementación real, esto podría subir los datos a un servicio en la nube
    // Por ahora, simplemente creamos un archivo JSON local
    try {
      // En web, el comportamiento será diferente
      if (kIsWeb) {
        print('Backup en web - exportando a JSON');
        final result = await exportInventoryToJson();
        return result != null;
      } else {
        // En dispositivos, crear un backup como un archivo JSON
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        
        // Crear carpeta de backups si no existe
        final backupDir = Directory('$path/backups');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        
        // Generar JSON como en exportInventoryToJson
        final items = await _itemController.getAllItems();
        final categories = await _categoryController.getAllCategories();
        final locations = await _locationController.getAllLocations();
        
        final Map<String, dynamic> jsonData = {
          'items': items.map((item) => {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'value': item.value,
            'category_id': item.categoryId,
            'location_id': item.locationId,
            'image_urls': item.imageUrls,
            'purchase_date': item.purchaseDate,
            'date_added': item.dateAdded,
            'last_updated': item.lastUpdated,
          }).toList(),
          'categories': categories.map((category) => {
            'id': category.id,
            'name': category.name,
            'description': category.description,
          }).toList(),
          'locations': locations.map((location) => {
            'id': location.id,
            'name': location.name,
            'description': location.description,
          }).toList(),
        };
        
        final jsonString = jsonEncode(jsonData);
        
        // Guardar como backup con fecha
        final timestamp = DateTime.now().toString().replaceAll(' ', '_').replaceAll(':', '-');
        final file = File('${backupDir.path}/backup_$timestamp.json');
        await file.writeAsString(jsonString);
        
        print('Backup guardado en: ${file.path}');
        return true;
      }
    } catch (e) {
      print('Error al crear backup: $e');
      return false;
    }
  }
  
  // Método auxiliar para compartir archivos
  Future<bool> shareFile(String filePath) async {
    try {
      if (kIsWeb) {
        print('Compartir archivos en web no está soportado directamente');
        return false;
      }
      
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareFiles([filePath], text: 'Inventario Doméstico');
        return true;
      }
      return false;
    } catch (e) {
      print('Error al compartir archivo: $e');
      return false;
    }
  }
}