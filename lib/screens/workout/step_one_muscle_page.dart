import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

class StepOneMusclePage extends StatelessWidget {
  final String selectedMuscle;
  final ValueChanged<String> onMuscleChanged;
  final VoidCallback onNext;

  const StepOneMusclePage({
    super.key,
    required this.selectedMuscle,
    required this.onMuscleChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> muscleGroups = ['Chest', 'Shoulder', 'Back', 'Bicep', 'Tricep', 'Legs', 'Abs', 'Cardio'];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.015),
          const Text('Step 1: Choose Muscle Focus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: screenHeight * 0.01),
          const Text('Select the targeted muscle anatomy zone you intend to train today.', style: TextStyle(fontSize: 14, color: Colors.white38)),
          SizedBox(height: screenHeight * 0.04),
          DropdownButtonFormField<String>(
            value: selectedMuscle,
            dropdownColor: AppColors.surface,
            decoration: const InputDecoration(labelText: 'Target Muscle Group'),
            items: muscleGroups.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) {
              if (val != null) onMuscleChanged(val);
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.065,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onNext,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Next: Select Exercise', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(width: screenWidth * 0.02),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }
}
