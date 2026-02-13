import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get serverUrl =>
    dotenv.get('SERVER_URL', fallback: 'http://localhost:8000');

final dio = Dio(
  BaseOptions(
    baseUrl: serverUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ),
);
