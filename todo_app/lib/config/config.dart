import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@singleton
class Config {
  String get serverUrl => dotenv.env['SERVER_URL'] ?? 'http://localhost:8000';
  String get bucketUrl => dotenv.env['BUCKET_URL'] ?? 'http://localhost:9000';
}

final CONFIG = Config();
