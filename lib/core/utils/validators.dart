class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _lettersWithSpaces = RegExp(r'^[a-zA-Z\s]+$');

  static bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

  static bool isLettersWithSpaces(String value) => _lettersWithSpaces.hasMatch(value);

  static bool isMobileNumber(String value) {
    final trimmed = value.trim();
    return trimmed.length == 10 && int.tryParse(trimmed) != null;
  }

  static bool isMinLength(String value, int minLength) => value.length >= minLength;
}
