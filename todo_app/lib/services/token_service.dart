import 'package:todo_app/cache/access_token.dart';
import 'package:todo_app/interfaces/token_manageable.dart';

// Service that implements token operations
class TokenService implements TokenManageable {
  @override
  Future<String?> getAccessToken() async {
    return await get_access_token();
  }

  @override
  Future<void> clearAccessToken() async {
    await remove_access_token();
  }

  @override
  Future<void> saveToken(String token) async {
    await set_access_token(token);
  }

  // Static methods for easier access
  static Future<String?> getToken() async {
    return await get_access_token();
  }

  static Future<void> clearToken() async {
    await remove_access_token();
  }

  static Future<void> setToken(String token) async {
    await set_access_token(token);
  }
}
