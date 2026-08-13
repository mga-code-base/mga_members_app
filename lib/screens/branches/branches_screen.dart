import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_theme.dart';
import '../../models/branch_model.dart';
import '../../services/resource_api_service.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  late Future<List<BranchItem>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = ResourceApiService.fetchAllBranches();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: AppTheme.dark.copyWith(dividerColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gym Branches'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.accent),
        ),
        body: FutureBuilder<List<BranchItem>>(
          future: _branchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Error: Unable to load gym branches.',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              );
            }

            final branches = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.04, vertical: 12),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.accent.withOpacity(0.6), width: 1.5),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: index == 0,
                    leading: const Icon(Icons.location_on, color: AppColors.accent, size: 30),
                    iconColor: AppColors.accent,
                    collapsedIconColor: Colors.white54,
                    title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                    subtitle: Text("${branch.address}, ${branch.city} - ${branch.pincode}", style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    children: [
                      Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fitness_center, size: 18, color: AppColors.accent.withOpacity(0.7)),
                                const SizedBox(width: 8),
                                const Text("Equipment Inventory", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 20),
                            if (branch.equipments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text("No equipment records documented at this branch.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white38, fontSize: 13)),
                              ),
                            ...branch.equipments.map((equip) => _buildEquipmentTile(equip)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEquipmentTile(EquipmentItem item) {
    final bool isWorking = item.isInWorkingCondition;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isWorking ? AppColors.accent.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
            child: Icon(
              isWorking ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 18,
              color: isWorking ? AppColors.accent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                Text("Routine: ${item.exerciseName}", style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              item.targetMuscle,
              style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
