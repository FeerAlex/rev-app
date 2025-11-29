import 'package:flutter/material.dart';

class FactionBasicInfoSection extends StatelessWidget {
  final String name;

  const FactionBasicInfoSection({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}

