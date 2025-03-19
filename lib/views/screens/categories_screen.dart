// views/screens/categories_screen.dart (actualizado)
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../controllers/category_controller.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryController _categoryController = CategoryController();
  late Future<List<Category>> _categoriesFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      _categoriesFuture = _categoryController.getAllCategories();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las categorías: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // views/screens/categories_screen.dart (continuación)
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadCategories();
      },
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? _buildErrorView()
          : _buildCategoryList(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategories,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryList() {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadCategories,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        final categories = snapshot.data ?? [];
        
        if (categories.isEmpty) {
          return const Center(
            child: Text('No hay categorías'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(category.description),
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.category, color: Colors.white),
                ),
                onTap: () {
                  // Aquí podrías navegar a una pantalla de detalles de la categoría
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleccionaste: ${category.name}')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}