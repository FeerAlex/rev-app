import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const MapPage({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: const Text('Карта'),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: const Center(
          child: Text(
            'Карта ресурсов',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

