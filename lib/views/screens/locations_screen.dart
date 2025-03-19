// views/screens/locations_screen.dart (actualizado)
import 'package:flutter/material.dart';
import '../../models/location.dart';
import '../../controllers/location_controller.dart';


class LocationsScreen extends StatefulWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final LocationController _locationController = LocationController();
  late Future<List<Location>> _locationsFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadLocations();
  }
  
  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      _locationsFuture = _locationController.getAllLocations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las ubicaciones: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadLocations();
      },
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? _buildErrorView()
          : _buildLocationList(),
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
            onPressed: _loadLocations,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationList() {
    return FutureBuilder<List<Location>>(
      future: _locationsFuture,
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
                  onPressed: _loadLocations,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        final locations = snapshot.data ?? [];
        
        if (locations.isEmpty) {
          return const Center(
            child: Text('No hay ubicaciones'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  location.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(location.description),
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.place, color: Colors.white),
                ),
                onTap: () {
                  // Aquí podrías navegar a una pantalla de detalles de la ubicación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleccionaste: ${location.name}')),
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