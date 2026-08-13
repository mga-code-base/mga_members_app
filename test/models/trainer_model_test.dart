import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/models/trainer_model.dart';

void main() {
  group('TrainerModel.fromJson', () {
    test('parses a fully-populated trainer with a plain scalar mobileNumber', () {
      final trainer = TrainerModel.fromJson({
        'trainerId': '77',
        'name': 'Coach Sam',
        'username': 'csam',
        'mobileNumber': '9123456780',
        'emailAddress': 'sam@example.com',
        'branchId': 'B-1',
      });

      expect(trainer.trainerId, '77');
      expect(trainer.name, 'Coach Sam');
      expect(trainer.username, 'csam');
      expect(trainer.mobileNumber, '9123456780');
      expect(trainer.emailAddress, 'sam@example.com');
      expect(trainer.branchId, 'B-1');
    });

    test('unwraps a Mongo-style {"\$numberLong": ...} mobileNumber', () {
      final trainer = TrainerModel.fromJson({
        'mobileNumber': {r'$numberLong': '9123456780'},
      });
      expect(trainer.mobileNumber, '9123456780');
    });

    test('a plain-scalar mobileNumber and a Mongo-wrapped one normalize to the same value', () {
      final plain = TrainerModel.fromJson({'mobileNumber': '9123456780'});
      final wrapped = TrainerModel.fromJson({
        'mobileNumber': {r'$numberLong': '9123456780'},
      });
      expect(plain.mobileNumber, wrapped.mobileNumber);
    });

    test('missing mobileNumber becomes an empty string, not null or a crash', () {
      final trainer = TrainerModel.fromJson({});
      expect(trainer.mobileNumber, '');
    });

    test('string fields default to empty string when missing', () {
      final trainer = TrainerModel.fromJson({});
      expect(trainer.trainerId, '');
      expect(trainer.name, '');
      expect(trainer.username, '');
      expect(trainer.emailAddress, '');
      expect(trainer.branchId, '');
    });
  });
}
