class TokenModel {
  final String access;
  final String refresh;
  final String? username;

  const TokenModel({
    required this.access,
    required this.refresh,
    this.username,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      username: json['user']['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'username': username,
    };
  }
}
