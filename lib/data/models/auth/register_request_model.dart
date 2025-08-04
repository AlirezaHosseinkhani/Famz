class RegisterRequestModel {
  final String email;
  final String username;
  final String password;
  final String password2;
  // final String? phoneNumber;

  const RegisterRequestModel({
    required this.email,
    required this.username,
    required this.password,
    required this.password2,
    // this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'password2': password2,
      // if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}
