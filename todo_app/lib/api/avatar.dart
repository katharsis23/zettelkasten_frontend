import 'package:dio/dio.dart';
//import 'package:todo_app/models/user.dart';
import 'package:todo_app/services/user_cache_service.dart';
import 'package:todo_app/services/token_service.dart';
import 'package:todo_app/injection.dart';
import 'package:todo_app/api/dio_client.dart';
import 'package:todo_app/config/config.dart';

class AvatarAPI {
  static Future<String?> get_avatar_url_v1() async {
    try {
      //TODO: Change null to default avatar URL in S3 bucket
      final token = await TokenService.getToken();
      if (token == null) {
        return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
      }
      final response = await getIt<DioClient>().dio.get(
        '/user/avatar',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final avatar_url = response.data['avatar_url'];
        await UserCacheService.saveAvatarUrl(avatar_url);
        return avatar_url;
      }
      return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
    } catch (e) {
      return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
    }
  }

  static Future<String?> get_avatar_url_v2() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
      }
      final response = await getIt<DioClient>().dio.get(
        '/user/avatar/v2',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final avatar_url = response.data['avatar_url'];
        await UserCacheService.saveAvatarUrl(avatar_url);
        return avatar_url;
      }
      return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
    } catch (e) {
      return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
    }
  }

  //TODO: Implement POST and DELETE methods
  //POST /user/avatar - Upload avatar using the real file *multipart/form-data* with Content-Type image/*
  //DELETE /user/avatar - Delete avatar
}
