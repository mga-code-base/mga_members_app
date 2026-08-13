import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/core/utils/validators.dart';

void main() {
  group('Validators.isValidEmail', () {
    test('accepts a normal email', () {
      expect(Validators.isValidEmail('name@domain.com'), isTrue);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.isValidEmail('  name@domain.com  '), isTrue);
    });

    test('rejects a value with no @', () {
      expect(Validators.isValidEmail('nameatdomain.com'), isFalse);
    });

    test('rejects a value with no domain extension', () {
      expect(Validators.isValidEmail('name@domain'), isFalse);
    });

    test('rejects an empty string', () {
      expect(Validators.isValidEmail(''), isFalse);
    });
  });

  group('Validators.isLettersWithSpaces', () {
    test('accepts letters and spaces only', () {
      expect(Validators.isLettersWithSpaces('John Doe'), isTrue);
    });

    test('rejects digits', () {
      expect(Validators.isLettersWithSpaces('John Doe 2'), isFalse);
    });

    test('rejects special characters', () {
      expect(Validators.isLettersWithSpaces('John_Doe!'), isFalse);
    });
  });

  group('Validators.isMobileNumber', () {
    test('accepts exactly 10 digits', () {
      expect(Validators.isMobileNumber('9876543210'), isTrue);
    });

    test('rejects fewer than 10 digits', () {
      expect(Validators.isMobileNumber('987654321'), isFalse);
    });

    test('rejects more than 10 digits', () {
      expect(Validators.isMobileNumber('98765432100'), isFalse);
    });

    test('rejects non-numeric input of the right length', () {
      expect(Validators.isMobileNumber('98765abcde'), isFalse);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.isMobileNumber('  9876543210  '), isTrue);
    });
  });

  group('Validators.isMinLength', () {
    test('accepts a string meeting the minimum length', () {
      expect(Validators.isMinLength('secret', 6), isTrue);
    });

    test('rejects a string shorter than the minimum length', () {
      expect(Validators.isMinLength('abc', 6), isFalse);
    });

    test('accepts a string exactly at the boundary', () {
      expect(Validators.isMinLength('123456', 6), isTrue);
    });
  });
}
