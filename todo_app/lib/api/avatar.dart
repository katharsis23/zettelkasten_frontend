import 'package:dio/dio.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
//import 'package:todo_app/models/user.dart';
import 'package:todo_app/services/user_cache_service.dart';
import 'package:todo_app/services/token_service.dart';
import 'package:todo_app/injection.dart';
import 'package:todo_app/api/dio_client.dart';
import 'package:todo_app/config/config.dart';

class AvatarAPI {
  static String _withCacheBusting(String url) {
    try {
      final uri = Uri.parse(url);
      final qp = Map<String, String>.from(uri.queryParameters);
      qp['v'] = DateTime.now().millisecondsSinceEpoch.toString();
      return uri.replace(queryParameters: qp).toString();
    } catch (e) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}v=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

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
        final busted = avatar_url is String
            ? _withCacheBusting(avatar_url)
            : avatar_url;
        if (busted is String) {
          await UserCacheService.saveAvatarUrl(busted);
          return busted;
        }
        return '${CONFIG.bucketUrl}/avatars/default_avatar.jpeg';
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

  static Future<bool> upload_avatar_v2(File avatarFile) async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('No access token');
    }

    final bytes = await avatarFile.readAsBytes();
    final filename = avatarFile.path.split(Platform.pathSeparator).last;
    final mimeType = lookupMimeType(avatarFile.path, headerBytes: bytes);
    final mediaType = (mimeType != null && mimeType.contains('/'))
        ? MediaType.parse(mimeType)
        : MediaType('application', 'octet-stream');

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: mediaType,
      ),
    });

    final response = await getIt<DioClient>().dio.post(
      '/user/avatar/v2',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 201) {
      final avatarUrl = response.data is Map
          ? response.data['avatar_url']
          : null;
      if (avatarUrl is String && avatarUrl.isNotEmpty) {
        await UserCacheService.replaceAvatarUrl(_withCacheBusting(avatarUrl));
      } else {
        await UserCacheService.refreshAvatarCache();
      }
      return true;
    }

    return false;
  }
}
