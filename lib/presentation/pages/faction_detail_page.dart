import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/constants/factions_list.dart';
import '../../../core/constants/work_reward.dart';
import '../bloc/faction/faction_bloc.dart';
import '../bloc/faction/faction_event.dart';
import '../widgets/faction_activities_block.dart';
import '../widgets/faction_certificate_block.dart';
import '../widgets/faction_decorations_section.dart';
import '../widgets/faction_reputation_block.dart';
import '../../../core/constants/reputation_level.dart';

class FactionDetailPage extends StatefulWidget {
  final Faction? faction;

  const FactionDetailPage({
    super.key,
    this.faction,
  });

  @override
  State<FactionDetailPage> createState() => _FactionDetailPageState();
}

class _FactionDetailPageState extends State<FactionDetailPage> {
  late bool _orderCompleted;
  late bool _ordersEnabled;
  late WorkReward? _workReward;
  late bool _workCompleted;
  late bool _hasCertificate;
  late bool _certificatePurchased;
  late bool _decorationRespectPurchased;
  late bool _decorationRespectUpgraded;
  late bool _decorationHonorPurchased;
  late bool _decorationHonorUpgraded;
  late bool _decorationAdorationPurchased;
  late bool _decorationAdorationUpgraded;
  late ReputationLevel _currentReputationLevel;
  late int _currentLevelExp;
  late ReputationLevel _targetReputationLevel;

  @override
  void initState() {
    super.initState();
    final faction = widget.faction;
    _orderCompleted = faction?.orderCompleted ?? false;
    _ordersEnabled = faction?.ordersEnabled ?? false;
    _workReward = faction?.workReward;
    _workCompleted = faction?.workCompleted ?? false;
    _hasCertificate = faction?.hasCertificate ?? false;
    _certificatePurchased = faction?.certificatePurchased ?? false;
    _decorationRespectPurchased = faction?.decorationRespectPurchased ?? false;
    _decorationRespectUpgraded = faction?.decorationRespectUpgraded ?? false;
    _decorationHonorPurchased = faction?.decorationHonorPurchased ?? false;
    _decorationHonorUpgraded = faction?.decorationHonorUpgraded ?? false;
    _decorationAdorationPurchased =
        faction?.decorationAdorationPurchased ?? false;
    _decorationAdorationUpgraded =
        faction?.decorationAdorationUpgraded ?? false;
    _currentReputationLevel = faction?.currentReputationLevel ?? ReputationLevel.indifference;
    _currentLevelExp = faction?.currentLevelExp ?? 0;
    _targetReputationLevel = faction?.targetReputationLevel ?? ReputationLevel.maximum;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _saveFaction() {
    if (widget.faction == null) {
      // Не должно быть возможности создать новую фракцию
      return;
    }

    final faction = Faction(
      id: widget.faction!.id,
      name: widget.faction!.name,
      currency: widget.faction!.currency,
      orderCompleted: _orderCompleted,
      ordersEnabled: _ordersEnabled,
      workReward: _workReward,
      workCompleted: _workCompleted,
      hasCertificate: _hasCertificate,
      certificatePurchased: _certificatePurchased,
      decorationRespectPurchased: _decorationRespectPurchased,
      decorationRespectUpgraded: _decorationRespectUpgraded,
      decorationHonorPurchased: _decorationHonorPurchased,
      decorationHonorUpgraded: _decorationHonorUpgraded,
      decorationAdorationPurchased: _decorationAdorationPurchased,
      decorationAdorationUpgraded: _decorationAdorationUpgraded,
      displayOrder: widget.faction!.displayOrder,
      isVisible: widget.faction!.isVisible,
      currentReputationLevel: _currentReputationLevel,
      currentLevelExp: _currentLevelExp,
      targetReputationLevel: _targetReputationLevel,
    );

    context.read<FactionBloc>().add(UpdateFactionEvent(faction));
    Navigator.of(context).pop();
  }

  bool _canFactionHaveOrders() {
    if (widget.faction == null) return false;
    final template = FactionsList.getTemplateByName(widget.faction!.name);
    return template?.orderReward != null;
  }

  bool _canFactionHaveWork() {
    if (widget.faction == null) return false;
    final template = FactionsList.getTemplateByName(widget.faction!.name);
    return template?.hasWork ?? false;
  }

  bool _canFactionHaveCertificate() {
    if (widget.faction == null) return false;
    final template = FactionsList.getTemplateByName(widget.faction!.name);
    return template?.hasCertificate ?? false;
  }

  void _deleteFaction() {
    if (widget.faction?.id == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скрыть фракцию?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<FactionBloc>()
                  .add(DeleteFactionEvent(widget.faction!.id!));
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Скрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.faction == null) {
      // Не должно быть возможности открыть страницу без фракции
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: const Center(child: Text('Фракция не выбрана')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.faction!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            FactionReputationBlock(
              faction: widget.faction!,
              currentReputationLevel: _currentReputationLevel,
              currentLevelExp: _currentLevelExp,
              targetReputationLevel: _targetReputationLevel,
              onCurrentLevelChanged: (value) {
                setState(() {
                  _currentReputationLevel = value;
                });
              },
              onLevelExpChanged: (value) {
                setState(() {
                  _currentLevelExp = value;
                });
              },
              onTargetLevelChanged: (value) {
                setState(() {
                  _targetReputationLevel = value;
                });
              },
            ),
            FactionActivitiesBlock(
              hasOrder: _ordersEnabled,
              workReward: _workReward,
              showOrderCheckbox: _canFactionHaveOrders(),
              showWorkInput: _canFactionHaveWork(),
              onHasOrderChanged: (value) {
                setState(() {
                  _ordersEnabled = value;
                  if (!value) {
                    _orderCompleted = false;
                  }
                });
              },
              onWorkRewardChanged: (value) {
                setState(() {
                  _workReward = value;
                  if (_workReward == null) {
                    _workCompleted = false;
                  }
                });
              },
            ),
            FactionCertificateBlock(
              hasCertificate: _hasCertificate,
              showCertificateCheckbox: _canFactionHaveCertificate(),
              onHasCertificateChanged: (value) {
                setState(() {
                  _hasCertificate = value;
                  if (!_hasCertificate) {
                    _certificatePurchased = false;
                  }
                });
              },
            ),
            FactionDecorationsSection(
              decorationRespectPurchased: _decorationRespectPurchased,
              decorationRespectUpgraded: _decorationRespectUpgraded,
              decorationHonorPurchased: _decorationHonorPurchased,
              decorationHonorUpgraded: _decorationHonorUpgraded,
              decorationAdorationPurchased: _decorationAdorationPurchased,
              decorationAdorationUpgraded: _decorationAdorationUpgraded,
              onRespectPurchasedChanged: (value) {
                setState(() {
                  _decorationRespectPurchased = value;
                });
              },
              onRespectUpgradedChanged: (value) {
                setState(() {
                  _decorationRespectUpgraded = value;
                });
              },
              onHonorPurchasedChanged: (value) {
                setState(() {
                  _decorationHonorPurchased = value;
                });
              },
              onHonorUpgradedChanged: (value) {
                setState(() {
                  _decorationHonorUpgraded = value;
                });
              },
              onAdorationPurchasedChanged: (value) {
                setState(() {
                  _decorationAdorationPurchased = value;
                });
              },
              onAdorationUpgradedChanged: (value) {
                setState(() {
                  _decorationAdorationUpgraded = value;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveFaction,
            child: const Text('Сохранить'),
          ),
        ),
      ),
    );
  }

}
