import 'package:todo_app/cache/user_cache.dart';
import 'package:todo_app/cache/avatar_cache.dart';
import 'dart:io';
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
    // Clear all user data from SharedPreferences
    await UserCache.clearUserData();

    // Clear avatar files from disk
    await AvatarCache.clearCache();
  }

  static Future<void> cacheUserFromAuthResult(User user) async {
    await UserCache.saveUserData(
      email: user.email,
      username: user.username,
      avatarUrl: user.avatar_url,
      isVerified: user.is_verified,
    );
  }

  // Avatar-specific methods with file caching
  static Future<String?> getAvatarUrl() async {
    // First try SharedPreferences
    final cachedUrl = await UserCache.getAvatarUrl();
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      return cachedUrl;
    }

    // Try to get cached file
    final user = await getCachedUser();
    if (user != null &&
        user.avatar_url != null &&
        user.avatar_url!.isNotEmpty) {
      final avatarUrl = user.avatar_url!;
      final cachedFile = await AvatarCache.getAvatarFile(avatarUrl);
      if (cachedFile != null) {
        // File exists and is fresh, return the URL
        // The widget will use the file directly
        return avatarUrl;
      }
    }

    // Return null if no avatar found - let AvatarWidget handle it
    return null;
  }

  static Future<void> saveAvatarUrl(String avatarUrl) async {
    // Save to SharedPreferences for fallback
    await UserCache.saveAvatarUrl(avatarUrl);

    // Also trigger file download for future use
    await AvatarCache.getAvatarFile(avatarUrl);
  }

  static Future<File?> getAvatarFile(String avatarUrl) async {
    return await AvatarCache.getAvatarFile(avatarUrl);
  }

  static Future<void> refreshAvatarCache() async {
    // Clear avatar cache and force refresh
    await AvatarCache.clearCache();
    await UserCache.saveAvatarUrl(''); // Clear URL to force refresh
  }
}
