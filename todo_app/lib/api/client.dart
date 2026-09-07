import 'package:todo_app/injection.dart';
import 'package:todo_app/api/dio_client.dart';

final dio = getIt<DioClient>().dio;
