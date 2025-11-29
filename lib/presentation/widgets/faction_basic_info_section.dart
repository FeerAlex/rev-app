import 'package:flutter/material.dart';

class FactionBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;

  const FactionBasicInfoSection({
    super.key,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: nameController,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Название фракции',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

