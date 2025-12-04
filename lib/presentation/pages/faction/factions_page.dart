import 'package:flutter/material.dart';
import '../../di/service_locator.dart';
import '../../../domain/usecases/calculate_time_to_currency_goal.dart';
import '../../../domain/usecases/calculate_time_to_reputation_goal.dart';
import '../../../domain/utils/reputation_exp.dart';
import '../../../domain/utils/reputation_helper.dart';
import 'factions_list_page.dart';
import '../../widgets/faction/faction_selection_dialog.dart';

class FactionsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const FactionsPage({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator();
    
    // Создаем зависимости через ServiceLocator
    final appSettingsRepository = serviceLocator.appSettingsRepository;
    final factionTemplateRepository = serviceLocator.factionTemplateRepository;
    
    final reputationExp = ReputationExp(
      appSettingsRepository,
      factionTemplateRepository,
    );
    final reputationHelper = ReputationHelper(reputationExp);
    
    final calculateTimeToCurrencyGoal = CalculateTimeToCurrencyGoal(
      appSettingsRepository,
      factionTemplateRepository,
    );
    
    final calculateTimeToReputationGoal = CalculateTimeToReputationGoal(
      factionTemplateRepository,
      appSettingsRepository,
    );
    
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
      body: SafeArea(
        child: FactionsListPage(
          reputationHelper: reputationHelper,
          calculateTimeToCurrencyGoal: calculateTimeToCurrencyGoal,
          calculateTimeToReputationGoal: calculateTimeToReputationGoal,
          appSettingsRepository: appSettingsRepository,
          factionTemplateRepository: factionTemplateRepository,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const FactionSelectionDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
