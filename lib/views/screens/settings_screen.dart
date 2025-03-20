// views/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Flags para opciones de configuración
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Español';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de apariencia
          _buildSectionHeader('Apariencia'),
          _buildSettingSwitch(
            title: 'Modo oscuro',
            subtitle: 'Cambiar entre tema claro y oscuro',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
                // Aquí implementarías el cambio real de tema
              });
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.dark_mode,
          ),
          
          _buildSettingTile(
            title: 'Idioma',
            subtitle: 'Seleccionar idioma de la aplicación',
            trailing: Text(_selectedLanguage),
            onTap: () {
              _showLanguageSelector();
            },
            icon: Icons.language,
          ),
          
          const Divider(),
          
          // Sección de notificaciones
          _buildSectionHeader('Notificaciones'),
          _buildSettingSwitch(
            title: 'Activar notificaciones',
            subtitle: 'Recibir alertas sobre tu inventario',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.notifications,
          ),
          
          const Divider(),
          
          // Sección de datos
          _buildSectionHeader('Datos'),
          _buildSettingTile(
            title: 'Exportar inventario',
            subtitle: 'Generar archivo CSV con tus datos',
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.upload_file,
          ),
          
          _buildSettingTile(
            title: 'Importar datos',
            subtitle: 'Cargar inventario desde archivo',
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.download,
          ),
          
          _buildSettingTile(
            title: 'Realizar copia de seguridad',
            subtitle: 'Guardar datos en la nube',
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.backup,
          ),
          
          const Divider(),
          
          // Sección Acerca de
          _buildSectionHeader('Acerca de'),
          _buildSettingTile(
            title: 'Versión',
            subtitle: AppConfig.appVersion,
            onTap: () {},
            icon: Icons.info_outline,
          ),
          
          _buildSettingTile(
            title: 'Términos y condiciones',
            subtitle: 'Información legal',
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.gavel,
          ),
          
          _buildSettingTile(
            title: 'Política de privacidad',
            subtitle: 'Uso de tus datos',
            onTap: () {
              _showFeatureNotImplementedMessage();
            },
            icon: Icons.privacy_tip,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Seleccionar idioma'),
        children: [
          _buildLanguageOption('Español'),
          _buildLanguageOption('English'),
          _buildLanguageOption('Français'),
          _buildLanguageOption('Deutsch'),
        ],
      ),
    );
  }
  
  Widget _buildLanguageOption(String language) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
        _showFeatureNotImplementedMessage();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(language),
      ),
    );
  }
  
  void _showFeatureNotImplementedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta función aún no está implementada'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}