class ProgressRecords {
  final List<MyRecord> chestRecords;
  final List<MyRecord> shoulderRecords;
  final List<MyRecord> backRecords;
  final List<MyRecord> bicepRecords;
  final List<MyRecord> tricepRecords;
  final List<MyRecord> absRecords;
  final List<MyRecord> legsRecords;
  final List<MyRecord> cardioRecords;

  ProgressRecords({
    required this.chestRecords,
    required this.shoulderRecords,
    required this.backRecords,
    required this.bicepRecords,
    required this.tricepRecords,
    required this.absRecords,
    required this.legsRecords,
    required this.cardioRecords,
  });

  factory ProgressRecords.fromJson(Map<String, dynamic> json) {
    return ProgressRecords(
      chestRecords: _parseList(json['chestRecords']),
      shoulderRecords: _parseList(json['shoulderRecords']),
      backRecords: _parseList(json['backRecords']),
      bicepRecords: _parseList(json['bicepRecords']),
      tricepRecords: _parseList(json['tricepRecords']),
      absRecords: _parseList(json['absRecords']),
      legsRecords: _parseList(json['legsRecords']),
      cardioRecords: _parseList(json['cardioRecords']),
    );
  }

  static List<MyRecord> _parseList(dynamic list) {
    if (list == null) return [];
    return List<MyRecord>.from(list.map((x) => MyRecord.fromJson(x)));
  }
}

class MyRecord {
  final String memberId;
  final String exerciseName;
  final String targetMuscle;
  final List<WorkoutSet> sets;
  final String date;

  MyRecord({
    required this.memberId,
    required this.exerciseName,
    required this.targetMuscle,
    required this.sets,
    required this.date,
  });

  factory MyRecord.fromJson(Map<String, dynamic> json) {
    var rawSets = json['sets'] as List?;
    return MyRecord(
      memberId: json['memberId']?.toString() ?? '',
      exerciseName: json['exerciseName']?.toString() ?? 'Unknown Exercise',
      targetMuscle: json['targetMuscle']?.toString() ?? 'General',
      date: json['date']?.toString() ?? 'N/A',
      sets: rawSets != null
          ? List<WorkoutSet>.from(rawSets.map((x) => WorkoutSet.fromJson(x)))
          : [],
    );
  }
}

class WorkoutSet {
  final double weight;
  final String scaleType;
  final int reps;
  final List<WorkoutSet> subsets;

  WorkoutSet({
    required this.weight,
    required this.scaleType,
    required this.reps,
    required this.subsets,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    var rawSubsets = json['subsets'] as List?;
    return WorkoutSet(
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      scaleType: json['scaleType']?.toString() ?? 'kg',
      reps: json['reps'] as int? ?? 0,
      subsets: rawSubsets != null
          ? List<WorkoutSet>.from(rawSubsets.map((x) => WorkoutSet.fromJson(x)))
          : [],
    );
  }
}

class PreviousWorkoutRecord {
  final String date;
  final List<TargetMuscleGroup> targetMuscles;

  PreviousWorkoutRecord({
    required this.date,
    required this.targetMuscles,
  });

  factory PreviousWorkoutRecord.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['targetMuscles'] as List? ?? json['targetMuscleGroups'] as List?;
    return PreviousWorkoutRecord(
      date: json['date']?.toString() ?? 'N/A',
      targetMuscles: rawGroups != null
          ? List<TargetMuscleGroup>.from(rawGroups.map((x) => TargetMuscleGroup.fromJson(x)))
          : [],
    );
  }
}

class TargetMuscleGroup {
  final String muscleName;
  final List<HistoricalWorkoutItem> workouts;

  TargetMuscleGroup({
    required this.muscleName,
    required this.workouts,
  });

  factory TargetMuscleGroup.fromJson(Map<String, dynamic> json) {
    var rawWorkouts = json['workouts'] as List?;
    return TargetMuscleGroup(
      muscleName: json['muscleName'] ?? json['targetMuscle'] ?? 'General',
      workouts: rawWorkouts != null
          ? List<HistoricalWorkoutItem>.from(rawWorkouts.map((x) => HistoricalWorkoutItem.fromJson(x)))
          : [],
    );
  }
}

class HistoricalWorkoutItem {
  final String exerciseName;
  final List<HistoricalSet> sets;

  HistoricalWorkoutItem({
    required this.exerciseName,
    required this.sets,
  });

  factory HistoricalWorkoutItem.fromJson(Map<String, dynamic> json) {
    var rawSets = json['sets'] as List?;
    return HistoricalWorkoutItem(
      exerciseName: json['exerciseName'] ?? 'Unknown Exercise',
      sets: rawSets != null
          ? List<HistoricalSet>.from(rawSets.map((x) => HistoricalSet.fromJson(x)))
          : [],
    );
  }
}

class HistoricalSet {
  final int reps;
  final double weight;

  HistoricalSet({
    required this.reps,
    required this.weight,
  });

  factory HistoricalSet.fromJson(Map<String, dynamic> json) {
    return HistoricalSet(
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
