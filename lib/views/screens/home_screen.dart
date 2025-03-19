// views/screens/home_screen.dart (actualizado)
import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'categories_screen.dart';
import 'locations_screen.dart';
import 'add_item_screen.dart';
import 'add_category_screen.dart';
import '../../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const InventoryScreen(),
    const CategoriesScreen(),
    const LocationsScreen(),
  ];
  
  final List<String> _titles = [
    'Inventario',
    'Categorías',
    'Ubicaciones',
  ];
  
  final List<IconData> _icons = [
    Icons.inventory,
    Icons.category,
    Icons.place,
  ];
  
  final List<Color> _colors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: _colors[_selectedIndex],
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda no implementada aún')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAppInfo(context);
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: List.generate(
          _titles.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
        selectedItemColor: _colors[_selectedIndex],
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddScreen(context);
        },
        backgroundColor: _colors[_selectedIndex],
        child: const Icon(Icons.add),
        tooltip: 'Añadir ${_getSingularTitle(_selectedIndex)}',
      ),
    );
  }
  
  // Obtener el título en singular
  String _getSingularTitle(int index) {
    String title = _titles[index];
    // Quitar la 's' final para obtener el singular
    return title.toLowerCase().substring(0, title.length - 1);
  }
  
  void _navigateToAddScreen(BuildContext context) {
    Widget screen;
    
    switch (_selectedIndex) {
      case 0:
        screen = const AddItemScreen();
        break;
      case 1:
        screen = const AddCategoryScreen();
        break;
      case 2:
        screen = const AddCategoryScreen() ;
        break;
      default:
        screen = const AddItemScreen();
        break;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((result) {
      if (result == true) {
        // Esto forzará la reconstrucción de toda la pantalla
        setState(() {
          // El Widget build volverá a ejecutarse, y las pantallas se actualizarán
          _screens[0] = const InventoryScreen();
          _screens[1] = const CategoriesScreen();
          _screens[2] = const LocationsScreen();
        });
      }
    });
  }
  
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConfig.appName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión: ${AppConfig.appVersion}'),
            SizedBox(height: 16),
            Text('Una aplicación para gestionar el inventario de los objetos de valor de tu hogar.'),
            SizedBox(height: 16),
            Text('Desarrollada con Flutter.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}