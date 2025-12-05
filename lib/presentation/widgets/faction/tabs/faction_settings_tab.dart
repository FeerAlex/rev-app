import 'package:flutter/material.dart';
import '../../../../domain/entities/reputation_level.dart';
import '../../../../domain/value_objects/work_reward.dart';
import '../faction_activities_block.dart';
import '../faction_goals_block.dart';

/// Виджет вкладки "Настройки" на странице деталей фракции
class FactionSettingsTab extends StatelessWidget {
  final bool ordersEnabled;
  final WorkReward? workReward;
  final bool showOrderCheckbox;
  final bool showWorkInput;
  final ReputationLevel currentReputationLevel;
  final ReputationLevel? targetReputationLevel;
  final bool wantsCertificate;
  final ValueChanged<bool> onHasOrderChanged;
  final ValueChanged<WorkReward?> onWorkRewardChanged;
  final ValueChanged<ReputationLevel?> onTargetLevelChanged;
  final ValueChanged<bool> onWantsCertificateChanged;

  const FactionSettingsTab({
    super.key,
    required this.ordersEnabled,
    required this.workReward,
    required this.showOrderCheckbox,
    required this.showWorkInput,
    required this.currentReputationLevel,
    required this.targetReputationLevel,
    required this.wantsCertificate,
    required this.onHasOrderChanged,
    required this.onWorkRewardChanged,
    required this.onTargetLevelChanged,
    required this.onWantsCertificateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          FactionGoalsBlock(
            currentReputationLevel: currentReputationLevel,
            targetReputationLevel: targetReputationLevel,
            wantsCertificate: wantsCertificate,
            onTargetLevelChanged: onTargetLevelChanged,
            onWantsCertificateChanged: onWantsCertificateChanged,
          ),
          FactionActivitiesBlock(
            hasOrder: ordersEnabled,
            workReward: workReward,
            showOrderCheckbox: showOrderCheckbox,
            showWorkInput: showWorkInput,
            wantsCertificate: wantsCertificate,
            targetReputationLevel: targetReputationLevel,
            onHasOrderChanged: onHasOrderChanged,
            onWorkRewardChanged: onWorkRewardChanged,
          ),
        ],
      ),
    );
  }
}

