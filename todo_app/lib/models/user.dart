import 'package:todo_app/cache/access_token.dart';

class User {
  String email;
  String username;
  String? password;
  String? avatar_url;
  bool is_verified;

  User({
    required this.email,
    required this.username,
    this.is_verified = false,
    this.password,
    this.avatar_url,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      is_verified: json['is_verified'] ?? false,
      avatar_url: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'password': password,
    'avatar_url': avatar_url,
    'is_verified': is_verified,
  };

  Map<String, dynamic> sendLoginData() => {
    'email': email,
    'password': password,
  };
  Map<String, dynamic> sendSignupData() => {
    'email': email,
    'password': password,
    'username': username,
  };

  Future<void> saveToken(String token) async {
    await set_access_token(token);
  }

  Future<void> saveTokenAndVerify(String token) async {
    await set_access_token(token);
    this.is_verified = true;
  }
}
