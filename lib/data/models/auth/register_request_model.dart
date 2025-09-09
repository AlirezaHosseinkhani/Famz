class RegisterRequestModel {
  final String phoneNumber;
  final String username;
  final String password;
  final String password2;

  // final String? phoneNumber;

  const RegisterRequestModel({
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.password2,
    // this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'username': username,
      'password': password,
      'password2': password2,
      // if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}
