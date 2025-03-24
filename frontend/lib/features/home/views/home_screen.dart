import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_money/core/models/user_model.dart';
import 'package:my_money/features/auth/bloc/auth_bloc.dart';
import 'package:my_money/features/finances/views/finances_screen.dart';
import 'package:my_money/shared/theme/app_theme.dart';
import 'package:my_money/shared/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _currentTitle = 'Inicio';

  final List<String> _sectionTitles = [
    'Inicio',
    'Finanzas',
    'Actividades',
    'Compras',
    'Comidas',
    'Recordatorios',
  ];

  final List<IconData> _sectionIcons = [
    Icons.dashboard,
    Icons.account_balance_wallet,
    Icons.checklist,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.notifications,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentTitle = _sectionTitles[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Abrir perfil de usuario
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Comidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Recordatorios',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            accountName: Text(widget.user.name ?? 'Usuario'),
            accountEmail: Text(widget.user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.name?.isNotEmpty == true
                    ? widget.user.name![0].toUpperCase()
                    : widget.user.email[0].toUpperCase(),
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          for (int i = 0; i < _sectionTitles.length; i++)
            ListTile(
              leading: Icon(_sectionIcons[i]),
              title: Text(_sectionTitles[i]),
              selected: _selectedIndex == i,
              onTap: () {
                _onItemTapped(i);
                Navigator.pop(context);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              // TODO: Abrir configuración
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              context.read<AuthBloc>().add(AuthLogoutEvent());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return FinancesScreen();
      case 2:
        return _buildPlaceholder('Módulo de Actividades');
      case 3:
        return _buildPlaceholder('Módulo de Compras');
      case 4:
        return _buildPlaceholder('Módulo de Planificación de Comidas');
      case 5:
        return _buildPlaceholder('Módulo de Recordatorios');
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, ${widget.user.name}!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido a tu panel de gestión familiar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  'Finanzas',
                  Icons.account_balance_wallet,
                  AppTheme.categoryColors['income']!,
                  'Administra tus ingresos y gastos',
                  () => _onItemTapped(1),
                ),
                _buildDashboardCard(
                  'Actividades',
                  Icons.checklist,
                  AppTheme.categoryColors['expense']!,
                  'Organiza las tareas familiares',
                  () => _onItemTapped(2),
                ),
                _buildDashboardCard(
                  'Compras',
                  Icons.shopping_cart,
                  AppTheme.categoryColors['loan']!,
                  'Gestiona tu lista de compras',
                  () => _onItemTapped(3),
                ),
                _buildDashboardCard(
                  'Comidas',
                  Icons.restaurant,
                  AppTheme.categoryColors['transfer']!,
                  'Planifica tus comidas semanales',
                  () => _onItemTapped(4),
                ),
                _buildDashboardCard(
                  'Recordatorios',
                  Icons.notifications,
                  AppTheme.infoColor,
                  'No olvides eventos importantes',
                  () => _onItemTapped(5),
                ),
                _buildDashboardCard(
                  'Configuración',
                  Icons.settings,
                  AppTheme.textTertiaryColor,
                  'Personaliza tu aplicación',
                  () {
                    // TODO: Abrir configuración
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.engineering,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Volver al inicio',
            onPressed: () => _onItemTapped(0),
            icon: Icons.home,
          ),
        ],
      ),
    );
  }
}
