import 'client.dart';
import 'package:dio/dio.dart';

Future<bool> check_server_health() async {
  try {
    final response = await dio.get('/health/healthcheck');
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } on DioException {
    return false;
  }
}
