import 'package:flutter/material.dart';
import '../faction/factions_page.dart';
import '../map/map_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages = [
    FactionsPage(scaffoldKey: _scaffoldKey),
    MapPage(scaffoldKey: _scaffoldKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _pages[_currentPage],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
              ),
              child: Text(
                'Rev App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Фракции'),
              selected: _currentPage == 0,
              onTap: () {
                setState(() {
                  _currentPage = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Карта'),
              selected: _currentPage == 1,
              onTap: () {
                setState(() {
                  _currentPage = 1;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

