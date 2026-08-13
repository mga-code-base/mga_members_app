import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

class StepTwoExercisePage extends StatelessWidget {
  final String selectedMuscle;
  final String? selectedExercise;
  final List<String> exerciseOptions;
  final ValueChanged<String?> onExerciseChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const StepTwoExercisePage({
    super.key,
    required this.selectedMuscle,
    required this.selectedExercise,
    required this.exerciseOptions,
    required this.onExerciseChanged,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.015),
          const Text('Step 2: Choose Exercise Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: screenHeight * 0.01),
          Text('Select a specific verified execution track mapped previously under your "$selectedMuscle" focus.', style: const TextStyle(fontSize: 14, color: Colors.white38)),
          SizedBox(height: screenHeight * 0.04),
          DropdownButtonFormField<String>(
            value: exerciseOptions.contains(selectedExercise) ? selectedExercise : null,
            dropdownColor: AppColors.surface,
            decoration: const InputDecoration(labelText: 'Exercise Name Selection'),
            disabledHint: const Text('No historical exercises tracked for selection', style: TextStyle(color: Colors.white38)),
            items: exerciseOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onExerciseChanged,
            validator: (v) => v == null ? 'Please map a routine focus element' : null,
          ),
          const Spacer(),
          Row(
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
                    onPressed: (selectedExercise == null || !exerciseOptions.contains(selectedExercise)) ? null : onNext,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Next: Logs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(width: screenWidth * 0.01),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }
}
