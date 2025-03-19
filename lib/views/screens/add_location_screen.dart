// views/screens/add_location_screen.dart
import 'package:flutter/material.dart';
import '../../controllers/location_controller.dart';
import '../../models/location.dart';

class AddLocationScreen extends StatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationController _locationController = LocationController();
  
  String _name = '';
  String _description = '';
  
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Ubicación'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.place),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    
                    // Descripción
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.description),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      maxLines: 3,
                      onSaved: (value) => _description = value ?? '',
                    ),
                    SizedBox(height: 24),
                    
                    // Botón de guardar
                    ElevatedButton.icon(
                      onPressed: _saveLocation,
                      icon: Icon(Icons.save),
                      label: Text('Guardar Ubicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Future<void> _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Verificar conexión al servidor (opcional)
        /* 
        bool isConnected = await ApiService.checkApiConnection();
        if (!isConnected) {
          throw Exception('No se puede conectar al servidor. Verifica tu conexión.');
        }
        */
        
        final location = Location(
          name: _name,
          description: _description,
        );
        
        await _locationController.createLocation(location);
        
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la ubicación: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}