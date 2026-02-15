// Interface for token operations
abstract class TokenManageable {
  Future<String?> getAccessToken();
  Future<void> clearAccessToken();
  Future<void> saveToken(String token);
}
