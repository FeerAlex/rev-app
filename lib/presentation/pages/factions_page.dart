import 'package:flutter/material.dart';
import 'factions_list_page.dart';
import 'settings_page.dart';
import 'faction_detail_page.dart';

class FactionsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const FactionsPage({super.key, this.scaffoldKey});

  @override
  State<FactionsPage> createState() => _FactionsPageState();
}

class _FactionsPageState extends State<FactionsPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FactionsListPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            widget.scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: const Text('Фракции'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Список',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FactionDetailPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
