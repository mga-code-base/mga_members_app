import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/models/workout_model.dart';

void main() {
  group('WorkoutSet.fromJson', () {
    test('parses a fully-populated set with no subsets', () {
      final set = WorkoutSet.fromJson({'weight': 80.5, 'scaleType': 'kg', 'reps': 8});

      expect(set.weight, 80.5);
      expect(set.scaleType, 'kg');
      expect(set.reps, 8);
      expect(set.subsets, isEmpty);
    });

    test('parses nested subsets recursively', () {
      final set = WorkoutSet.fromJson({
        'weight': 80.5,
        'scaleType': 'kg',
        'reps': 8,
        'subsets': [
          {'weight': 60.0, 'scaleType': 'kg', 'reps': 12},
        ],
      });

      expect(set.subsets.length, 1);
      expect(set.subsets.first.weight, 60.0);
      expect(set.subsets.first.reps, 12);
    });

    test('missing numeric fields default to zero, not a crash', () {
      final set = WorkoutSet.fromJson({});
      expect(set.weight, 0.0);
      expect(set.reps, 0);
      expect(set.scaleType, 'kg');
    });

    test('an integer weight from the backend still parses as a double', () {
      final set = WorkoutSet.fromJson({'weight': 80, 'reps': 5});
      expect(set.weight, 80.0);
    });
  });

  group('MyRecord.fromJson', () {
    test('parses a fully-populated record with sets', () {
      final record = MyRecord.fromJson({
        'memberId': 'M-1',
        'exerciseName': 'Bench Press',
        'targetMuscle': 'Chest',
        'date': '2026-08-01',
        'sets': [
          {'weight': 60.0, 'scaleType': 'kg', 'reps': 10},
        ],
      });

      expect(record.memberId, 'M-1');
      expect(record.exerciseName, 'Bench Press');
      expect(record.targetMuscle, 'Chest');
      expect(record.date, '2026-08-01');
      expect(record.sets.length, 1);
    });

    test('missing fields fall back to the same defaults the screens rely on', () {
      final record = MyRecord.fromJson({});
      expect(record.memberId, '');
      expect(record.exerciseName, 'Unknown Exercise');
      expect(record.targetMuscle, 'General');
      expect(record.date, 'N/A');
      expect(record.sets, isEmpty);
    });
  });

  group('ProgressRecords.fromJson', () {
    test('parses all eight muscle-group buckets independently', () {
      final progress = ProgressRecords.fromJson({
        'chestRecords': [
          {'exerciseName': 'Bench Press'},
        ],
        'legsRecords': [
          {'exerciseName': 'Squat'},
          {'exerciseName': 'Lunge'},
        ],
      });

      expect(progress.chestRecords.length, 1);
      expect(progress.legsRecords.length, 2);
      expect(progress.shoulderRecords, isEmpty);
      expect(progress.backRecords, isEmpty);
      expect(progress.bicepRecords, isEmpty);
      expect(progress.tricepRecords, isEmpty);
      expect(progress.absRecords, isEmpty);
      expect(progress.cardioRecords, isEmpty);
    });
  });
}
