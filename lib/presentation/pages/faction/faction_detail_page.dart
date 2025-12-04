import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/repositories/faction_template_repository.dart';
import '../../../domain/value_objects/work_reward.dart';
import '../../bloc/faction/faction_bloc.dart';
import '../../bloc/faction/faction_event.dart';
import '../../widgets/faction/faction_activities_block.dart';
import '../../widgets/faction/faction_currency_block.dart';
import '../../widgets/faction/faction_reputation_block.dart';
import '../../widgets/faction/faction_certificate_block.dart';
import '../../widgets/faction/faction_goals_block.dart';
import '../../widgets/faction/faction_decorations_section.dart';
import '../../../domain/entities/reputation_level.dart';

class FactionDetailPage extends StatefulWidget {
  final Faction? faction;
  final FactionTemplateRepository factionTemplateRepository;

  const FactionDetailPage({
    super.key,
    this.faction,
    required this.factionTemplateRepository,
  });

  @override
  State<FactionDetailPage> createState() => _FactionDetailPageState();
}

class _FactionDetailPageState extends State<FactionDetailPage> {
  int _currentIndex = 0;
  late int _currency;
  late bool _orderCompleted;
  late bool _ordersEnabled;
  late WorkReward? _workReward;
  late bool _workCompleted;
  late bool _certificatePurchased;
  late bool _decorationRespectPurchased;
  late bool _decorationRespectUpgraded;
  late bool _decorationHonorPurchased;
  late bool _decorationHonorUpgraded;
  late bool _decorationAdorationPurchased;
  late bool _decorationAdorationUpgraded;
  late ReputationLevel _currentReputationLevel;
  late int _currentLevelExp;
  late ReputationLevel? _targetReputationLevel;
  late bool _wantsCertificate;

  @override
  void initState() {
    super.initState();
    final faction = widget.faction;
    _currency = faction?.currency ?? 0;
    _orderCompleted = faction?.orderCompleted ?? false;
    _ordersEnabled = faction?.ordersEnabled ?? false;
    _workReward = faction?.workReward;
    _workCompleted = faction?.workCompleted ?? false;
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
    _targetReputationLevel = faction?.targetReputationLevel;
    _wantsCertificate = faction?.wantsCertificate ?? false;
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

    final template = widget.factionTemplateRepository.getTemplateByName(widget.faction!.name);
    final faction = Faction(
      id: widget.faction!.id,
      name: widget.faction!.name,
      currency: _currency,
      orderCompleted: _orderCompleted,
      ordersEnabled: _ordersEnabled,
      workReward: _workReward,
      workCompleted: _workCompleted,
      hasCertificate: template?.hasCertificate ?? false,
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
      wantsCertificate: _wantsCertificate,
    );

    context.read<FactionBloc>().add(UpdateFactionEvent(faction));
    Navigator.of(context).pop();
  }

  bool _canFactionHaveOrders() {
    if (widget.faction == null) return false;
    final template = widget.factionTemplateRepository.getTemplateByName(widget.faction!.name);
    return template?.orderReward != null;
  }

  bool _canFactionHaveWork() {
    if (widget.faction == null) return false;
    final template = widget.factionTemplateRepository.getTemplateByName(widget.faction!.name);
    return template?.hasWork ?? false;
  }

  /// Проверяет, что все украшения куплены и улучшены
  bool _areAllDecorationsPurchasedAndUpgraded() {
    return _decorationRespectPurchased &&
        _decorationRespectUpgraded &&
        _decorationHonorPurchased &&
        _decorationHonorUpgraded &&
        _decorationAdorationPurchased &&
        _decorationAdorationUpgraded;
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
        body: SafeArea(
          child: const Center(child: Text('Фракция не выбрана')),
        ),
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFaction,
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Вкладка "Настройки"
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
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
                        // Если оба поля 0, сбрасываем completed
                        if (_workReward != null && _workReward!.currency == 0 && _workReward!.exp == 0) {
                          _workCompleted = false;
                        }
                      });
                    },
                  ),
                  FactionGoalsBlock(
                    currentReputationLevel: _currentReputationLevel,
                    targetReputationLevel: _targetReputationLevel,
                    wantsCertificate: _wantsCertificate,
                    onTargetLevelChanged: (value) {
                      setState(() {
                        _targetReputationLevel = value;
                      });
                    },
                    onWantsCertificateChanged: (value) {
                      setState(() {
                        _wantsCertificate = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Вкладка "Инвентарь"
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  FactionCurrencyBlock(
                    currency: _currency,
                    onCurrencyChanged: (value) {
                      setState(() {
                        _currency = value;
                      });
                    },
                  ),
                  FactionReputationBlock(
                    currentReputationLevel: _currentReputationLevel,
                    currentLevelExp: _currentLevelExp,
                    onCurrentLevelChanged: (value) {
                      setState(() {
                        _currentReputationLevel = value;
                        // Если целевой уровень стал невалидным (ниже или равен текущему), переключаем на следующий доступный
                        if (_targetReputationLevel != null && 
                            _targetReputationLevel!.value <= value.value) {
                          // Находим следующий доступный уровень (минимальный уровень выше текущего)
                          final nextLevel = ReputationLevel.values.firstWhere(
                            (level) => level.value > value.value,
                            orElse: () => ReputationLevel.maximum,
                          );
                          _targetReputationLevel = nextLevel;
                        }
                      });
                    },
                    onLevelExpChanged: (value) {
                      setState(() {
                        _currentLevelExp = value;
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
                        // Если сняли "Куплено", автоматически снимаем "Улучшено"
                        if (!value) {
                          _decorationRespectUpgraded = false;
                        }
                        // Если сняли галочку с украшения и сертификат куплен, снимаем галочку с сертификата
                        if (!value && _certificatePurchased) {
                          _certificatePurchased = false;
                        }
                      });
                    },
                    onRespectUpgradedChanged: (value) {
                      setState(() {
                        _decorationRespectUpgraded = value;
                        // Если сняли "Улучшено" и сертификат куплен, снимаем галочку с сертификата
                        if (!value && _certificatePurchased) {
                          _certificatePurchased = false;
                        }
                      });
                    },
                    onHonorPurchasedChanged: (value) {
                      setState(() {
                        _decorationHonorPurchased = value;
                        // Если сняли "Куплено", автоматически снимаем "Улучшено"
                        if (!value) {
                          _decorationHonorUpgraded = false;
                        }
                        // Если сняли галочку с украшения и сертификат куплен, снимаем галочку с сертификата
                        if (!value && _certificatePurchased) {
                          _certificatePurchased = false;
                        }
                      });
                    },
                    onHonorUpgradedChanged: (value) {
                      setState(() {
                        _decorationHonorUpgraded = value;
                        // Если сняли "Улучшено" и сертификат куплен, снимаем галочку с сертификата
                        if (!value && _certificatePurchased) {
                          _certificatePurchased = false;
                        }
                      });
                    },
                    onAdorationPurchasedChanged: (value) {
                      setState(() {
                        _decorationAdorationPurchased = value;
                        // Если сняли "Куплено", автоматически снимаем "Улучшено"
                        if (!value) {
                          _decorationAdorationUpgraded = false;
                        }
                        // Если сняли галочку с украшения и сертификат куплен, снимаем галочку с сертификата
                        if (!value && _certificatePurchased) {
                          _certificatePurchased = false;
                        }
                      });
                    },
                    onAdorationUpgradedChanged: (value) {
                      setState(() {
                        _decorationAdorationUpgraded = value;
                        // Если сняли "Улучшено" и сертификат куплен, снимаем галочку с сертификата
                        if (!value && _certificatePurchased) {
                          _certificatePurchased = false;
                        }
                      });
                    },
                  ),
                  FactionCertificateBlock(
                    faction: widget.faction!,
                    factionTemplateRepository: widget.factionTemplateRepository,
                    certificatePurchased: _certificatePurchased,
                    onCertificatePurchasedChanged: (value) {
                      if (value == true) {
                        // Проверяем, что все украшения куплены и улучшены
                        if (!_areAllDecorationsPurchasedAndUpgraded()) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Невозможно купить сертификат'),
                              content: const Text(
                                'Для покупки сертификата необходимо купить и улучшить все украшения фракции:\n\n'
                                '• Уважение\n'
                                '• Почтение\n'
                                '• Преклонение',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Понятно'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                      }
                      setState(() {
                        _certificatePurchased = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Инвентарь',
          ),
        ],
      ),
    );
  }

}
