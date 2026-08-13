import 'package:flutter/material.dart';
import '../../controllers/set_controllers.dart';
import '../../core/config/app_colors.dart';
import '../../models/workout_model.dart';

class StepThreeLoggingPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedMuscle;
  final String? selectedExercise;
  final List<MyRecord> targetedHistoryList;
  final bool isHistoryLoading;
  final List<SetInputController> setControllers;
  final VoidCallback onAddNewSet;
  final VoidCallback onSetState;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const StepThreeLoggingPage({
    super.key,
    required this.formKey,
    required this.selectedMuscle,
    required this.selectedExercise,
    required this.targetedHistoryList,
    required this.isHistoryLoading,
    required this.setControllers,
    required this.onAddNewSet,
    required this.onSetState,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.015),
            const Text(
              'Step 3: Log Performance Sets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Document load parameters, targets, and active structural drops for your $selectedExercise routine.',
              style: const TextStyle(fontSize: 14, color: Colors.white38),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (isHistoryLoading)
              const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: AppColors.accent)))
            else if (targetedHistoryList.isNotEmpty) ...[
              const Text(
                'Previous Performance Metrics Logged:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: targetedHistoryList.length,
                  itemBuilder: (context, index) {
                    final record = targetedHistoryList[index];
                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60)),
                          const SizedBox(height: 6),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: record.sets.asMap().entries.map((setEntry) {
                                  final sIdx = setEntry.key + 1;
                                  final sData = setEntry.value;
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      'Set $sIdx: ${sData.weight}${sData.scaleType} × ${sData.reps}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Logged Sets Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70)),
                IconButton(
                  onPressed: onAddNewSet,
                  icon: const Icon(Icons.add_circle, color: AppColors.accent, size: 24),
                  tooltip: 'Insert Set Row',
                )
              ],
            ),
            Expanded(
              child: setControllers.isEmpty
                  ? const Center(
                      child: Text(
                        'No routine entries initialized. Tap the add icon above to declare targets.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white24, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      itemCount: setControllers.length,
                      itemBuilder: (context, index) => _buildSetRowCard(setControllers[index], index + 1, screenWidth),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.065,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white60,
                          side: const BorderSide(color: Colors.white10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: onBack,
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: setControllers.isEmpty ? null : onSubmit,
                        child: const Text('Submit Log', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRowCard(SetInputController setCtrl, int setNum, double screenWidth) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Set $setNum", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                const Spacer(),
                DropdownButton<String>(
                  value: setCtrl.scaleType,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.bold),
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: "kg", child: Text("kg")),
                    DropdownMenuItem(value: "lbs", child: Text("lbs")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setCtrl.scaleType = val;
                      onSetState();
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: setCtrl.weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Weight', contentPadding: EdgeInsets.all(12)),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: TextFormField(
                    controller: setCtrl.repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps', contentPadding: EdgeInsets.all(12)),
                  ),
                ),
              ],
            ),
            if (setCtrl.subsets.isNotEmpty) ...[
              const SizedBox(height: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: setCtrl.subsets.asMap().entries.map((entry) {
                  return _buildSubsetRow(entry.value, entry.key, screenWidth);
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setCtrl.subsets.add(SubsetInputController(weightCtrl: TextEditingController(), repsCtrl: TextEditingController()));
                  onSetState();
                },
                icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.accent),
                label: const Text("Add Subset", style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubsetRow(SubsetInputController subCtrl, int subIdx, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text("↳ S_${subIdx + 1}: ", style: const TextStyle(fontSize: 13, color: Colors.white38, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: subCtrl.weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Wt (Opt)', contentPadding: EdgeInsets.all(10)),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: TextFormField(
              controller: subCtrl.repsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps (Opt)', contentPadding: EdgeInsets.all(10)),
            ),
          ),
        ],
      ),
    );
  }
}
