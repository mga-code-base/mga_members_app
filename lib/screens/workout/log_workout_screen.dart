import 'package:flutter/material.dart';
import '../../controllers/set_controllers.dart';
import '../../core/config/app_colors.dart';
import '../../core/config/app_theme.dart';
import '../../models/workout_model.dart';
import '../../services/auth_cache_service.dart';
import '../../services/resource_api_service.dart';
import 'step_one_muscle_page.dart';
import 'step_three_logging_page.dart';
import 'step_two_exercise_page.dart';

class LogWorkoutWizard extends StatefulWidget {
  const LogWorkoutWizard({super.key});

  @override
  State<LogWorkoutWizard> createState() => _LogWorkoutWizardState();
}

class _LogWorkoutWizardState extends State<LogWorkoutWizard> {
  final _formKey = GlobalKey<FormState>();
  final List<SetInputController> _setControllers = [];
  final PageController _pageController = PageController();

  int _currentStepIndex = 0;
  List<MyRecord> _targetedExerciseHistory = [];
  List<String> _exerciseOptions = [];

  bool _isSaving = false;
  bool _isHistoryLoading = false;

  String _selectedMuscle = 'Chest';
  String? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _populateExerciseDropdownCascadeFromServer(_selectedMuscle);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var ctrl in _setControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _populateExerciseDropdownCascadeFromServer(String muscleGroup) async {
    setState(() {
      _exerciseOptions = [];
      _selectedExercise = null;
    });

    try {
      final List<String> globalCatalogExercises = await ResourceApiService.fetchExercises(muscleGroup);
      setState(() {
        _exerciseOptions = globalCatalogExercises;
        if (_exerciseOptions.isNotEmpty) {
          _selectedExercise = _exerciseOptions.first;
        }
      });
    } catch (_) {}
  }

  Future<void> _fetchTargetedHistoryForStepThree() async {
    if (_selectedExercise == null) return;

    setState(() {
      _isHistoryLoading = true;
      _targetedExerciseHistory = [];
    });

    try {
      final String? cachedId = await AuthCacheService.getCachedMemberId();
      if (cachedId == null || cachedId.isEmpty) {
        setState(() => _isHistoryLoading = false);
        return;
      }

      final int parsedMemberId = int.tryParse(cachedId) ?? 0;
      final Map<String, dynamic> rawJson = await ResourceApiService.fetchPreviousRecords(
        memberId: parsedMemberId,
        targetMuscle: _selectedMuscle,
        exerciseName: _selectedExercise!,
      );

      final List<dynamic> historyDataList = rawJson['allMyRecords'] ?? [];

      setState(() {
        _targetedExerciseHistory = historyDataList.map((x) => MyRecord.fromJson(x)).toList();
        _isHistoryLoading = false;
      });
    } catch (_) {
      setState(() {
        _targetedExerciseHistory = [];
        _isHistoryLoading = false;
      });
    }
  }

  void _addNewEmptySetLine() {
    setState(() {
      _setControllers.add(SetInputController(
        weightCtrl: TextEditingController(),
        repsCtrl: TextEditingController(),
        scaleType: 'kg',
      ));
    });
  }

  void navigateToPage(int index) {
    setState(() => _currentStepIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    if (index == 2) {
      _fetchTargetedHistoryForStepThree();
    }
  }

  void _submitLogPayload() async {
    if (_selectedExercise == null) return;

    final validSetsControllersList = _setControllers.where((set) {
      return set.weightCtrl.text.trim().isNotEmpty && set.repsCtrl.text.trim().isNotEmpty;
    }).toList();

    if (validSetsControllersList.isEmpty) {
      _showSnack('Please complete at least one set entry before submitting.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final String? cachedId = await AuthCacheService.getCachedMemberId();

    final Map<String, dynamic> finalPayload = {
      "memberId": cachedId,
      "exerciseName": _selectedExercise,
      "targetMuscle": _selectedMuscle,
      "date": "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
      "sets": validSetsControllersList.map((set) {
        final validSubsetsList = set.subsets.where((sub) {
          return sub.weightCtrl.text.trim().isNotEmpty && sub.repsCtrl.text.trim().isNotEmpty;
        }).map((sub) {
          return {
            "weight": double.tryParse(sub.weightCtrl.text.trim()) ?? 0.0,
            "scaleType": set.scaleType,
            "reps": int.tryParse(sub.repsCtrl.text.trim()) ?? 0,
          };
        }).toList();

        return {
          "weight": double.tryParse(set.weightCtrl.text.trim()) ?? 0.0,
          "scaleType": set.scaleType,
          "reps": int.tryParse(set.repsCtrl.text.trim()) ?? 0,
          "subsets": validSubsetsList
        };
      }).toList()
    };
    bool success = await ResourceApiService.createWorkoutRecord(finalPayload);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      _showSnack('Workout entry compiled and saved!', isError: false);
      Navigator.pop(context, true);
    } else {
      _showSnack('Failed to sync workout log data.', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Log Workout (Step ${_currentStepIndex + 1}/3)',
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.accent),
          leading: _currentStepIndex > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => navigateToPage(_currentStepIndex - 1),
                )
              : null,
        ),
        body: _isSaving
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: List.generate(3, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index <= _currentStepIndex ? AppColors.accent : Colors.white10,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StepOneMusclePage(
                            selectedMuscle: _selectedMuscle,
                            onMuscleChanged: (val) {
                              setState(() => _selectedMuscle = val);
                              _populateExerciseDropdownCascadeFromServer(_selectedMuscle);
                            },
                            onNext: () => navigateToPage(1),
                          ),
                          StepTwoExercisePage(
                            selectedMuscle: _selectedMuscle,
                            selectedExercise: _selectedExercise,
                            exerciseOptions: _exerciseOptions,
                            onExerciseChanged: (val) => setState(() => _selectedExercise = val),
                            onBack: () => navigateToPage(0),
                            onNext: () => navigateToPage(2),
                          ),
                          StepThreeLoggingPage(
                            formKey: _formKey,
                            selectedMuscle: _selectedMuscle,
                            selectedExercise: _selectedExercise,
                            targetedHistoryList: _targetedExerciseHistory,
                            isHistoryLoading: _isHistoryLoading,
                            setControllers: _setControllers,
                            onAddNewSet: _addNewEmptySetLine,
                            onSetState: () => setState(() {}),
                            onBack: () => navigateToPage(1),
                            onSubmit: _submitLogPayload,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
