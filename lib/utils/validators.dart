/// Utility class for form validation
class Validators {
  /// Validates that a field is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a string can be parsed to an integer
  static String? validateInt(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer for $fieldName';
    }

    return null;
  }

  /// Validates that a string can be parsed to a double
  static String? validateDouble(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number for $fieldName';
    }

    return null;
  }

  /// Validates that a string can be parsed to a positive double
  static String? validatePositiveDouble(String? value, String fieldName) {
    final doubleError = validateDouble(value, fieldName);
    if (doubleError != null) {
      return doubleError;
    }

    final doubleValue = double.parse(value!);
    if (doubleValue <= 0) {
      return '$fieldName should be greater than zero';
    }

    return null;
  }

  /// Validates that a string can be parsed to a non-negative double
  static String? validateNonNegativeDouble(String? value, String fieldName) {
    final doubleError = validateDouble(value, fieldName);
    if (doubleError != null) {
      return doubleError;
    }

    final doubleValue = double.parse(value!);
    if (doubleValue < 0) {
      return '$fieldName cannot be negative';
    }

    return null;
  }

  /// Validates a date string in the format dd/mm/yyyy
  static String? validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Please enter a valid date in the format dd/mm/yyyy';
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31) {
        return 'Day should be between 1 and 31';
      }

      if (month < 1 || month > 12) {
        return 'Month should be between 1 and 12';
      }

      if (year < 2000 || year > 2100) {
        return 'Year should be between 2000 and 2100';
      }

      // Check if the date is valid (e.g., Feb 30 is not valid)
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return 'Please enter a valid date';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  /// Validates an email address
  static String? validateEmail(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a phone number (simple validation)
  static String? validatePhone(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    // Remove spaces, hyphens, etc.
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it's numeric and of reasonable length
    if (!RegExp(r'^\d{8,15}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates text length
  static String? validateLength(
      String? value, String fieldName, int minLength, int maxLength) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName should be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName should not exceed $maxLength characters';
    }

    return null;
  }
}
