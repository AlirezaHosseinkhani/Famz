class Validators {
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  //
  // static bool isValidPhoneNumber(String phoneNumber) {
  //   final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
  //   return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  // }
  //
  // static String? validateEmailOrPhone(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter email or phone number';
  //   }
  //
  //   // Check if it's an email
  //   if (value.contains('@')) {
  //     return validateEmail(value);
  //   } else {
  //     return validatePhoneNumber(value);
  //   }
  // }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final number = value.trim();

    // Only digits allowed
    if (!RegExp(r'^[0-9]+$').hasMatch(number)) {
      return "Phone number must contain digits only";
    }

    // Must not start with zero
    if (number.startsWith('0')) {
      return "Phone number must not start with 0";
    }

    // Length check (7–12 digits for general case)
    if (number.length < 7 || number.length > 12) {
      return "must be between 7 and 12 digits";
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // static String? validatePhoneNumber(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter a phone number';
  //   }
  //
  //   final phoneRegExp = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
  //   if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
  //     return 'Please enter a valid phone number';
  //   }
  //
  //   return null;
  // }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  static String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 6) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (RegExp(r'[0-9@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Names cannot include numbers, symbols (e.g., @, #) or special characters';
    }

    return null;
  }

  static bool isValidOtp(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2 &&
        name.trim().length <= 50 &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim());
  }

  static String formatPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      return '+98${digitsOnly.substring(1)}';
    } else if (digitsOnly.length == 10) {
      return '+98$digitsOnly';
    }
    return phoneNumber;
  }
}
