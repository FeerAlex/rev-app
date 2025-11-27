import 'package:flutter/material.dart';
import '../../../domain/entities/reputation_level.dart';

class FactionBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final ReputationLevel reputationLevel;
  final ValueChanged<ReputationLevel> onReputationLevelChanged;

  const FactionBasicInfoSection({
    super.key,
    required this.nameController,
    required this.reputationLevel,
    required this.onReputationLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Название фракции',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ReputationLevel>(
          value: reputationLevel,
          decoration: const InputDecoration(
            labelText: 'Уровень репутации',
            border: OutlineInputBorder(),
          ),
          items: ReputationLevel.values.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: level.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(level.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onReputationLevelChanged(value);
            }
          },
        ),
      ],
    );
  }
}

