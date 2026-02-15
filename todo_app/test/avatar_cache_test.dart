import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:todo_app/cache/avatar_cache.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  final String documentsPath;

  _FakePathProviderPlatform(this.documentsPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return documentsPath;
  }
}

String _expectedCacheFileNameForUrl(String url) {
  final bytes = url.codeUnits;
  final hash = bytes.fold<int>(0, (prev, byte) => prev + byte);
  return 'avatar_$hash.jpg';
}

void main() {
  group('AvatarCache (unit, no network)', () {
    late Directory tempDir;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('avatar_cache_test_');
      PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

      await AvatarCache.init();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deleteCachedAvatarForUrl deletes only matching file', () async {
      const url1 = 'https://example.com/avatars/a.jpeg';
      const url2 = 'https://example.com/avatars/b.jpeg';

      final cacheDir = Directory('${tempDir.path}/avatars');
      expect(await cacheDir.exists(), isTrue);

      final file1 = File(
        '${cacheDir.path}/${_expectedCacheFileNameForUrl(url1)}',
      );
      final file2 = File(
        '${cacheDir.path}/${_expectedCacheFileNameForUrl(url2)}',
      );

      await file1.writeAsBytes([1, 2, 3]);
      await file2.writeAsBytes([4, 5, 6]);

      expect(await file1.exists(), isTrue);
      expect(await file2.exists(), isTrue);

      await AvatarCache.deleteCachedAvatarForUrl(url1);

      expect(await file1.exists(), isFalse);
      expect(await file2.exists(), isTrue);
    });

    test('clearCache removes all cached avatar files', () async {
      const url1 = 'https://example.com/avatars/a.jpeg';
      const url2 = 'https://example.com/avatars/b.jpeg';

      final cacheDir = Directory('${tempDir.path}/avatars');
      final file1 = File(
        '${cacheDir.path}/${_expectedCacheFileNameForUrl(url1)}',
      );
      final file2 = File(
        '${cacheDir.path}/${_expectedCacheFileNameForUrl(url2)}',
      );

      await file1.writeAsBytes([1]);
      await file2.writeAsBytes([2]);

      expect(await file1.exists(), isTrue);
      expect(await file2.exists(), isTrue);

      await AvatarCache.clearCache();

      expect(await file1.exists(), isFalse);
      expect(await file2.exists(), isFalse);
    });
  });
}
