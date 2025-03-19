// views/screens/locations_screen.dart (mejorado)
import 'package:flutter/material.dart';
import '../../models/location.dart';
import '../../controllers/location_controller.dart';
import '../../config/app_theme.dart';
import '../widgets/custom_card.dart';
import 'location_details_screen.dart';
import 'add_location_screen.dart';

class LocationsScreen extends StatefulWidget {
  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final LocationController _locationController = LocationController();
  late Future<List<Location>> _locationsFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  
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
    return Scaffold(
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(),
          
          // Lista de ubicaciones
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildLocationList(),
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
          hintText: 'Buscar ubicaciones...',
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
            _loadLocations();
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
            onPressed: _loadLocations,
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
  
  Widget _buildLocationList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadLocations();
      },
      child: FutureBuilder<List<Location>>(
        future: _locationsFuture,
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
                    onPressed: _loadLocations,
                    icon: Icon(Icons.refresh),
                    label: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          List<Location> locations = snapshot.data ?? [];
          
          // Filtrar ubicaciones si hay una búsqueda
          if (_searchQuery.isNotEmpty) {
            locations = locations.where((location) => 
              location.name.toLowerCase().contains(_searchQuery) ||
              location.description.toLowerCase().contains(_searchQuery)
            ).toList();
          }
          
          if (locations.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return _buildLocationCard(location);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildLocationCard(Location location) {
    // Iconos para diferentes tipos de ubicaciones (puedes personalizarlos)
    IconData getLocationIcon(String name) {
      name = name.toLowerCase();
      if (name.contains('sala') || name.contains('salón'))
        return Icons.weekend;
      else if (name.contains('cocina'))
        return Icons.kitchen;
      else if (name.contains('baño'))
        return Icons.bathtub;
      else if (name.contains('dormitorio') || name.contains('habitación'))
        return Icons.bed;
      else if (name.contains('garaje'))
        return Icons.garage;
      else if (name.contains('jardín') || name.contains('terraza'))
        return Icons.deck;
      else if (name.contains('oficina') || name.contains('despacho'))
        return Icons.business_center;
      else
        return Icons.place;
    }
    
    // Obtener el icono adecuado
    final icon = getLocationIcon(location.name);
    
    return CustomCard(
      padding: EdgeInsets.all(0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetailsScreen(location: location),
          ),
        ).then((result) {
          if (result == true) {
            setState(() {
              _loadLocations();
            });
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              AppTheme.locationColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.locationColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.locationColor,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (location.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        location.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place_outlined,
            size: 72,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty 
                ? 'No hay ubicaciones disponibles' 
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
                MaterialPageRoute(builder: (context) => AddLocationScreen()),
              ).then((result) {
                if (result == true) {
                  _loadLocations();
                }
              });
            },
            icon: Icon(Icons.add),
            label: Text('Añadir Ubicación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.locationColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}