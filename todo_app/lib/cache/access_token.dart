import 'package:shared_preferences/shared_preferences.dart';

Future<void> set_access_token(String token) async {
  const String key = 'access_token';
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, token);
}

Future<String?> get_access_token() async {
  const String key = 'access_token';
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> remove_access_token() async {
  const String key = 'access_token';
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
