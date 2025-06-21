import 'package:flutter/material.dart';
import 'package:frontend/screens/items_page.dart';
import 'package:frontend/screens/stockmovement_page.dart';
import 'package:frontend/services/auth_service.dart';

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  int _selectedPage = 0;

  final List<Widget> _pages = [
    const ItemsPage(),
    const StockMovementsPage(),
    // TODO: Users page
    // TODO: Admin page (to create categories and suppliers)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Padding(
                  padding: EdgeInsets.only(top: 50, left: 40),
                  child: Text(
                    'Inventory System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
            ListTile(
                selected: _selectedPage == 0,
                selectedTileColor: Colors.grey,
                title: Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: _selectedPage == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedPage == 0 ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedPage = 0);
                }),
            ListTile(
                selected: _selectedPage == 1,
                selectedTileColor: Colors.grey,
                title: Text(
                  'Stock Movement',
                  style: TextStyle(
                    fontWeight: _selectedPage == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedPage == 1 ? Colors.black : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedPage = 1);
                }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _pages[_selectedPage],
      ),
    );
  }
}
