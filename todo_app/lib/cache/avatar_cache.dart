import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AvatarCache {
  static const String _cacheDirName = 'avatars';
  static late Directory _cacheDir;

  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/$_cacheDirName');

    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
  }

  static Future<File?> _getCacheFile(String url) async {
    try {
      final filename = _generateFilename(url);
      final file = File('${_cacheDir.path}/$filename');
      return file;
    } catch (e) {
      return null;
    }
  }

  static String _generateFilename(String url) {
    // Generate unique filename from URL
    final bytes = url.codeUnits;
    final hash = bytes.fold<int>(0, (prev, byte) => prev + byte);
    return 'avatar_$hash.jpg';
  }

  static Future<File?> getAvatarFile(String url) async {
    final cacheFile = await _getCacheFile(url);
    if (cacheFile == null) return null;

    // Check if file exists and is not too old (7 days)
    if (await cacheFile.exists()) {
      final stat = await cacheFile.stat();
      final age = DateTime.now().difference(stat.modified);
      if (age.inDays < 7) {
        return cacheFile;
      }
    }

    // Download and cache
    return await _downloadAndCache(url, cacheFile);
  }

  static Future<File?> _downloadAndCache(String url, File cacheFile) async {
    try {
      print('DEBUG: Downloading avatar from: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('DEBUG: Saving avatar to: ${cacheFile.path}');
        await cacheFile.writeAsBytes(response.bodyBytes);
        print('DEBUG: Avatar file saved successfully');
        return cacheFile;
      }
    } catch (e) {
      print('DEBUG: Error downloading avatar: $e');
    }

    return null;
  }

  static Future<void> clearCache() async {
    try {
      if (await _cacheDir.exists()) {
        await for (final file in _cacheDir.list()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error clearing avatar cache: $e');
    }
  }

  static Future<int> getCacheSize() async {
    int totalSize = 0;
    try {
      if (await _cacheDir.exists()) {
        await for (final file in _cacheDir.list()) {
          if (file is File) {
            final stat = await file.stat();
            totalSize += stat.size;
          }
        }
      }
    } catch (e) {
      print('Error calculating cache size: $e');
    }
    return totalSize;
  }
}
