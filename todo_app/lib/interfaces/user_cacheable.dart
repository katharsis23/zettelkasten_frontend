import 'package:todo_app/models/user.dart';

// Interface for cache operations
abstract class UserCacheable {
  Future<void> cacheUserData();
  static Future<User?> getCachedUser() async => throw UnimplementedError();
  static Future<bool> hasCachedUser() async => throw UnimplementedError();
  static Future<void> clearCachedUser() async => throw UnimplementedError();
  static Future<void> cacheUserFromAuthResult(User user) async =>
      throw UnimplementedError();

  static Future<String?> getAvatarUrl() async => throw UnimplementedError();
  static Future<void> saveAvatarUrl(String avatarUrl) async =>
      throw UnimplementedError();
}
