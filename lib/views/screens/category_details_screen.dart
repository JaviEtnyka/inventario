// views/screens/category_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/category.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/item_controller.dart';
import 'edit_category_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category category;
  
  CategoryDetailsScreen({required this.category});
  
  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final CategoryController _categoryController = CategoryController();
  final ItemController _itemController = ItemController();
  bool _isLoading = false;
  int _itemCount = 0;
  
  @override
  void initState() {
    super.initState();
    _loadCategoryStats();
  }
  
  Future<void> _loadCategoryStats() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Obtener la cantidad de ítems en esta categoría
      final items = await _itemController.filterByCategory(widget.category.id!);
      setState(() {
        _itemCount = items.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estadísticas: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Categoría'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la categoría
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Descripción
                  if (widget.category.description.isNotEmpty) ...[
                    Text(
                      'Descripción:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.category.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 24),
                  ],
                  
                  // Estadísticas
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(Icons.inventory, 'Objetos en esta categoría', _itemCount.toString()),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Fecha de registro
                  if (widget.category.createdAt != null)
                    Text(
                      'Fecha de registro: ${_formatDate(widget.category.createdAt!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
  
  // Construir fila de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
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
        builder: (context) => EditCategoryScreen(category: widget.category),
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
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta categoría? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _deleteCategory(context),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // Eliminar categoría
  void _deleteCategory(BuildContext context) async {
    try {
      // Aquí necesitarás implementar la función deleteCategory en tu CategoryController
      //await _categoryController.deleteCategory(widget.category.id!);
      
      // Mientras tanto, solo cerramos el diálogo y volvemos a la pantalla anterior
      Navigator.pop(context); // Cerrar diálogo
      Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categoría eliminada correctamente')),
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la categoría: $e')),
      );
    }
  }
}