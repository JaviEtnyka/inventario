// views/screens/inventory_screen.dart (actualizado)
import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../controllers/item_controller.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ItemController _itemController = ItemController();
  late Future<List<Item>> _itemsFuture;
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      _itemsFuture = _itemController.getAllItems();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los items: $e';
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
        await _loadItems();
      },
      child: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? _buildErrorView()
          : _buildItemList(),
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
            onPressed: _loadItems,
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemList() {
    return FutureBuilder<List<Item>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadItems,
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        final items = snapshot.data ?? [];
        
        if (items.isEmpty) {
          return Center(
            child: Text('No hay items en el inventario'),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valor: €${item.value.toStringAsFixed(2)}'),
                    if (item.categoryName != null) 
                      Text('Categoría: ${item.categoryName}'),
                    if (item.locationName != null) 
                      Text('Ubicación: ${item.locationName}'),
                  ],
                ),
                isThreeLine: true,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.inventory, color: Colors.white),
                ),
                onTap: () {
                  // Navegación a la pantalla de detalles (pendiente de implementar)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleccionaste: ${item.name}')),
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