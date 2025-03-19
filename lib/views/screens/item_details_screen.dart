// views/screens/item_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item.dart';
import '../../controllers/item_controller.dart';
import 'edit_item_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;
  final ItemController _itemController = ItemController();
  
  ItemDetailsScreen({Key? key, required this.item}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Formatear el valor como moneda
    final currencyFormat = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 2,
    );
    
    // Obtener las URLs de las imágenes
    List<String> imageUrls = item.getImageUrlsList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería de imágenes
            if (imageUrls.isNotEmpty)
              _buildImageGallery(imageUrls),
            
            const SizedBox(height: 24),
            
            // Nombre del item
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Valor
            Text(
              'Valor: ${currencyFormat.format(item.value)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Categoría y ubicación
            if (item.categoryName != null)
              _buildInfoRow(Icons.category, 'Categoría', item.categoryName!),
            
            if (item.locationName != null)
              _buildInfoRow(Icons.place, 'Ubicación', item.locationName!),
            
            const SizedBox(height: 16),
            
            // Descripción
            const Text(
              'Descripción:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 24),
            
            // Fecha de registro
            if (item.dateAdded != null)
              Text(
                'Fecha de registro: ${_formatDate(item.dateAdded!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Construir galería de imágenes
  Widget _buildImageGallery(List<String> imageUrls) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Construir fila de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  // Formatear fecha
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // Navegar a pantalla de edición
  void _navigateToEditScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
    }
  }
  
  // Mostrar diálogo de confirmación para eliminar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este item? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _deleteItem(context),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // Eliminar item
  void _deleteItem(BuildContext context) async {
    try {
      await _itemController.deleteItem(item.id!);
      Navigator.pop(context); // Cerrar diálogo
      Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el item: $e')),
      );
    }
  }
}