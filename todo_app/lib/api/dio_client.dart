import 'package:dio/dio.dart';
import 'package:todo_app/config/config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DioClient {
  late final Dio _dio;

  Dio get dio => _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: CONFIG.serverUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Add interceptors for logging, auth, etc.
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // logPrint: (obj) => print(obj),
      ),
    );
  }
}
