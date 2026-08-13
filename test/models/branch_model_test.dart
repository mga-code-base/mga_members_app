import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/models/branch_model.dart';

void main() {
  group('EquipmentItem.fromJson', () {
    test('parses a fully-populated equipment entry', () {
      final item = EquipmentItem.fromJson({
        'name': 'Treadmill',
        'exerciseName': 'Running',
        'targetMuscle': 'Cardio',
        'isInWorkingCondition': true,
      });

      expect(item.name, 'Treadmill');
      expect(item.exerciseName, 'Running');
      expect(item.targetMuscle, 'Cardio');
      expect(item.isInWorkingCondition, isTrue);
    });

    test('isInWorkingCondition is false for any non-true value, not a crash', () {
      expect(EquipmentItem.fromJson({}).isInWorkingCondition, isFalse);
      expect(EquipmentItem.fromJson({'isInWorkingCondition': false}).isInWorkingCondition, isFalse);
      expect(EquipmentItem.fromJson({'isInWorkingCondition': null}).isInWorkingCondition, isFalse);
    });

    test('string fields default to empty string when missing', () {
      final item = EquipmentItem.fromJson({});
      expect(item.name, '');
      expect(item.exerciseName, '');
      expect(item.targetMuscle, '');
    });
  });

  group('BranchItem.fromJson', () {
    test('parses a fully-populated branch with nested equipment', () {
      final branch = BranchItem.fromJson({
        'branchId': 'B-1',
        'name': 'Downtown',
        'adminId': ['A-1', 'A-2'],
        'pincode': 560001,
        'address': '123 Main St',
        'city': 'Metropolis',
        'equipments': [
          {'name': 'Treadmill', 'exerciseName': 'Running', 'targetMuscle': 'Cardio', 'isInWorkingCondition': true},
        ],
      });

      expect(branch.branchId, 'B-1');
      expect(branch.name, 'Downtown');
      expect(branch.adminId, ['A-1', 'A-2']);
      expect(branch.pincode, 560001);
      expect(branch.equipments.length, 1);
      expect(branch.equipments.first.name, 'Treadmill');
    });

    test('missing equipments list defaults to empty, not null', () {
      final branch = BranchItem.fromJson({'branchId': 'B-2'});
      expect(branch.equipments, isEmpty);
    });

    test('missing adminId list defaults to empty', () {
      final branch = BranchItem.fromJson({'branchId': 'B-3'});
      expect(branch.adminId, isEmpty);
    });
  });

  group('BranchResponse.fromJson', () {
    test('parses a list of branches from the allBranches key', () {
      final response = BranchResponse.fromJson({
        'allBranches': [
          {'branchId': 'B-1', 'name': 'One'},
          {'branchId': 'B-2', 'name': 'Two'},
        ],
      });

      expect(response.allBranches.length, 2);
      expect(response.allBranches.first.name, 'One');
    });

    test('missing allBranches key results in an empty list', () {
      final response = BranchResponse.fromJson({});
      expect(response.allBranches, isEmpty);
    });
  });
}
