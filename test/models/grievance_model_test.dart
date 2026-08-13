import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/models/grievance_model.dart';

void main() {
  group('Grievance.fromJson', () {
    test('parses a fully-populated closed ticket', () {
      final grievance = Grievance.fromJson({
        'id': 'G-1',
        'branchId': 'B-1',
        'memberId': 'M-1',
        'issueType': 'Equipment',
        'title': 'Broken treadmill',
        'description': 'Belt is torn.',
        'status': 'CLOSED',
        'resolution': 'Replaced belt.',
        'closureDate': '2026-08-01',
      });

      expect(grievance.id, 'G-1');
      expect(grievance.branchId, 'B-1');
      expect(grievance.memberId, 'M-1');
      expect(grievance.issueType, 'Equipment');
      expect(grievance.title, 'Broken treadmill');
      expect(grievance.status, 'CLOSED');
      expect(grievance.resolution, 'Replaced belt.');
      expect(grievance.closureDate, '2026-08-01');
    });

    test('resolution and closureDate stay null for an open ticket', () {
      final grievance = Grievance.fromJson({'id': 'G-2', 'status': 'PENDING'});
      expect(grievance.resolution, isNull);
      expect(grievance.closureDate, isNull);
    });

    test('status defaults to UNKNOWN when missing', () {
      final grievance = Grievance.fromJson({});
      expect(grievance.status, 'UNKNOWN');
    });

    test('coerces a non-string id to String', () {
      final grievance = Grievance.fromJson({'id': 101});
      expect(grievance.id, '101');
    });
  });

  group('Grievance.toJson', () {
    test('only includes the fields the create-grievance endpoint expects', () {
      final grievance = Grievance(
        id: 'ignored-locally',
        branchId: 'B-1',
        memberId: 'M-1',
        issueType: 'Trainer',
        title: 'Late arrival',
        description: 'Trainer was 20 minutes late.',
        status: 'PENDING',
      );

      final json = grievance.toJson();

      expect(json['branchId'], 'B-1');
      expect(json['memberId'], 'M-1');
      expect(json['issueType'], 'Trainer');
      expect(json['title'], 'Late arrival');
      expect(json['description'], 'Trainer was 20 minutes late.');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('resolution'), isFalse);
    });
  });
}
