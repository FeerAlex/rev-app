import 'package:flutter/material.dart';
import 'factions_list_page.dart';
import 'faction_detail_page.dart';

class FactionsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const FactionsPage({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: const Text('Фракции'),
      ),
      body: const FactionsListPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FactionDetailPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
