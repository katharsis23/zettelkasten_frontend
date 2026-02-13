import 'package:todo_app/cache/access_token.dart';

class User {
  String email;
  String username;
  String? password;
  String? avatar_url;
  late bool is_verified = false;

  User({
    required this.email,
    required this.username,
    this.password,
    this.avatar_url,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      avatar_url: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'avatar_url': avatar_url,
    };
  }

  Map<String, dynamic> send_login_data() {
    return {'email': email, 'password': password, 'username': username};
  }

  void set_avatar(String avatar_url) {
    this.avatar_url = avatar_url;
  }

  Future<void> check_verified() async {
    // Checks the access token from Shared Preferences
    // If the token, set is_verified to true
    // If the token is not found, set is_verified to false
    String? access_token = await get_access_token();
    if (access_token != null) {
      is_verified = true;
    }
  }

  Future<void> set_access_token_and_set_is_verified(String access_token) async {
    //Uses when set access token
    //A wrapper method to directly set the access token and immediately set is_verified=True
    await set_access_token(access_token);
    is_verified = true;
  }
}
