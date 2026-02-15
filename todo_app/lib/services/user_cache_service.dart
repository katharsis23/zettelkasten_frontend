import 'package:todo_app/cache/user_cache.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/interfaces/user_cacheable.dart';

// Service that implements cache operations
class UserCacheService implements UserCacheable {
  @override
  Future<void> cacheUserData() async {
    // This would need a user instance, so let's fix the interface
    throw UnimplementedError('Use cacheUserFromAuthResult instead');
  }

  static Future<User?> getCachedUser() async {
    final userData = await UserCache.getUserData();
    if (userData == null) return null;

    return User(
      email: userData['email'],
      username: userData['username'],
      avatar_url: userData['avatar_url'],
      is_verified: userData['is_verified'],
    );
  }

  static Future<bool> hasCachedUser() async {
    return await UserCache.hasUserData();
  }

  static Future<void> clearCachedUser() async {
    await UserCache.clearUserData();
  }

  static Future<void> cacheUserFromAuthResult(User user) async {
    await UserCache.saveUserData(
      email: user.email,
      username: user.username,
      avatarUrl: user.avatar_url,
      isVerified: user.is_verified,
    );
  }

  static Future<String?> getAvatarUrl() async {
    return await UserCache.getAvatarUrl();
  }

  static Future<void> saveAvatarUrl(String avatarUrl) async {
    await UserCache.saveAvatarUrl(avatarUrl);
  }
}
