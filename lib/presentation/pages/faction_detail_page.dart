import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/faction.dart';
import '../bloc/faction/faction_bloc.dart';
import '../bloc/faction/faction_event.dart';
import '../widgets/faction_activities_section.dart';
import '../widgets/faction_decorations_section.dart';

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
  late bool _hasOrder;
  late bool _orderCompleted;
  late bool _hasCertificate;
  late bool _certificatePurchased;
  late bool _decorationRespectPurchased;
  late bool _decorationRespectUpgraded;
  late bool _decorationHonorPurchased;
  late bool _decorationHonorUpgraded;
  late bool _decorationAdorationPurchased;
  late bool _decorationAdorationUpgraded;

  @override
  void initState() {
    super.initState();
    final faction = widget.faction;
    _hasOrder = faction?.hasOrder ?? false;
    _orderCompleted = faction?.orderCompleted ?? false;
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
      hasOrder: _hasOrder,
      orderCompleted: _orderCompleted,
      workCurrency: widget.faction!.workCurrency,
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
    );

    context.read<FactionBloc>().add(UpdateFactionEvent(faction));
    Navigator.of(context).pop();
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
            child: const Text('Удалить'),
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
            FactionActivitiesSection(
              hasOrder: _hasOrder,
              hasCertificate: _hasCertificate,
              onHasOrderChanged: (value) {
                setState(() {
                  _hasOrder = value;
                  if (!_hasOrder) {
                    _orderCompleted = false;
                  }
                });
              },
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
            // Секция сертификата
            if (_hasCertificate) _buildCertificateSection(),
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

  Widget _buildCertificateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified, color: Colors.purple[300], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Сертификат',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: Colors.purple,
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                Checkbox(
                  value: _certificatePurchased,
                  onChanged: (value) {
                    setState(() {
                      _certificatePurchased = value ?? false;
                    });
                  },
                  activeColor: Colors.purple,
                ),
                const Text('Куплен', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
