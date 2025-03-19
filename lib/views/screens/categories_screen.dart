// views/screens/categories_screen.dart (mejorado)
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../controllers/category_controller.dart';
import '../../config/app_theme.dart';
import '../widgets/custom_card.dart';
import 'category_details_screen.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryController _categoryController = CategoryController();
  late Future<List<Category>> _categoriesFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(),
          
          // Lista de categorías
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar categorías...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
            _loadCategories();
          });
        },
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(color: AppTheme.errorColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCategories,
            icon: Icon(Icons.refresh),
            label: Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadCategories();
      },
      child: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadCategories,
                    icon: Icon(Icons.refresh),
                    label: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          List<Category> categories = snapshot.data ?? [];
          
          // Filtrar categorías si hay una búsqueda
          if (_searchQuery.isNotEmpty) {
            categories = categories.where((category) => 
              category.name.toLowerCase().contains(_searchQuery) ||
              category.description.toLowerCase().contains(_searchQuery)
            ).toList();
          }
          
          if (categories.isEmpty) {
            return _buildEmptyState();
          }
          
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryCard(Category category) {
    return CustomCard(
      padding: EdgeInsets.all(0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(category: category),
          ),
        ).then((result) {
          if (result == true) {
            setState(() {
              _loadCategories();
            });
          }
        });
      },
      child: Stack(
        children: [
          // Contenido principal
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category,
                    color: AppTheme.categoryColor,
                    size: 30,
                  ),
                ),
                SizedBox(height: 12),
                
                // Nombre
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Descripción
                if (category.description.isNotEmpty)
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Indicador visual en la esquina
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.categoryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topRight: Radius.circular(AppTheme.borderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 72,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay categorías disponibles' 
                : 'No se encontraron resultados para "$_searchQuery"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryScreen()),
              ).then((result) {
                if (result == true) {
                  _loadCategories();
                }
              });
            },
            icon: Icon(Icons.add),
            label: Text('Añadir Categoría'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.categoryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}