// views/screens/add_item_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../controllers/item_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/location_controller.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../widgets/image_picker_widget.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ItemController _itemController = ItemController();
  final CategoryController _categoryController = CategoryController();
  final LocationController _locationController = LocationController();
  
  String _name = '';
  String _description = '';
  double _value = 0.0;
  int? _categoryId;
  int? _locationId;
  List<File> _imageFiles = [];
  
  List<Category> _categories = [];
  List<Location> _locations = [];
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadCategoriesAndLocations();
  }
  
  Future<void> _loadCategoriesAndLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final categoriesFuture = _categoryController.getAllCategories();
      final locationsFuture = _locationController.getAllLocations();
      
      _categories = await categoriesFuture;
      _locations = await locationsFuture;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar categorías y ubicaciones: $e';
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
      appBar: AppBar(
        title: Text('Añadir Item'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildForm(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: TextStyle(color: Colors.red)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategoriesAndLocations,
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            SizedBox(height: 16),
            
            // Valor
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Valor (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un valor';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
              onSaved: (value) => _value = double.parse(value!),
            ),
            SizedBox(height: 16),
            
            // Categoría
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _categoryId,
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Sin categoría'),
                ),
                ..._categories.map((category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _categoryId = value;
                });
              },
              // Añadir validación
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una categoría';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Ubicación
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              value: _locationId,
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Sin ubicación'),
                ),
                ..._locations.map((location) {
                  return DropdownMenuItem<int?>(
                    value: location.id,
                    child: Text(location.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _locationId = value;
                });
              },
              // Añadir validación
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una ubicación';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Descripción
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              onSaved: (value) => _description = value ?? '',
            ),
            SizedBox(height: 24),
            
            // Selector de imágenes
            ImagePickerWidget(
              images: _imageFiles,
              onImagesChanged: (images) {
                setState(() {
                  _imageFiles = images;
                });
              },
            ),
            SizedBox(height: 24),
            
            // Botón de guardar
            ElevatedButton.icon(
              onPressed: _saveItem,
              icon: Icon(Icons.save),
              label: Text('Guardar Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      try {
        final item = Item(
          name: _name,
          description: _description,
          value: _value,
          categoryId: _categoryId,
          locationId: _locationId,
        );
        
        await _itemController.createItem(item, _imageFiles);
        
        // Volver a la pantalla anterior con resultado positivo
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al guardar el item: $e';
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      }
    }
  }
}