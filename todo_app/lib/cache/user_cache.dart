import 'package:shared_preferences/shared_preferences.dart';

class UserCache {
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'user_username';
  static const String _avatarUrlKey = 'user_avatar_url';
  static const String _isVerifiedKey = 'user_is_verified';

  static Future<void> saveUserData({
    required String email,
    required String username,
    String? avatarUrl,
    bool isVerified = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_usernameKey, username);
    if (avatarUrl != null) {
      await prefs.setString(_avatarUrlKey, avatarUrl);
    }
    await prefs.setBool(_isVerifiedKey, isVerified);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final username = prefs.getString(_usernameKey);
    final avatarUrl = prefs.getString(_avatarUrlKey);
    final isVerified = prefs.getBool(_isVerifiedKey) ?? false;

    if (email == null || username == null) {
      return null;
    }

    return {
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
    };
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_avatarUrlKey);
    await prefs.remove(_isVerifiedKey);
  }

  static Future<bool> hasUserData() async {
    final userData = await getUserData();
    return userData != null;
  }

  //Separated method for avatar since we have a separated endpoint for it
  static Future<String> saveAvatarUrl(String avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarUrlKey, avatarUrl);
    return avatarUrl;
  }

  static Future<String?> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarUrlKey);
  }
}
