import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/cache/avatar_cache.dart';
import 'package:todo_app/cache/user_cache.dart';
import 'package:todo_app/services/user_cache_service.dart';

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
  group('UserCacheService avatar caching (unit, no network)', () {
    late Directory tempDir;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      tempDir = await Directory.systemTemp.createTemp(
        'user_cache_service_test_',
      );
      PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
      await AvatarCache.init();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'replaceAvatarUrl deletes old cached file and keeps new cached file',
      () async {
        const oldUrl = 'https://example.com/avatars/old.jpeg';
        const newUrl = 'https://example.com/avatars/new.jpeg?v=123';

        await UserCache.saveAvatarUrl(oldUrl);

        final cacheDir = Directory('${tempDir.path}/avatars');
        final oldFile = File(
          '${cacheDir.path}/${_expectedCacheFileNameForUrl(oldUrl)}',
        );
        final newFile = File(
          '${cacheDir.path}/${_expectedCacheFileNameForUrl(newUrl)}',
        );

        await oldFile.writeAsBytes([1, 2, 3]);
        await newFile.writeAsBytes([4, 5, 6]);

        expect(await oldFile.exists(), isTrue);
        expect(await newFile.exists(), isTrue);

        await UserCacheService.replaceAvatarUrl(newUrl);

        final storedUrl = await UserCache.getAvatarUrl();
        expect(storedUrl, equals(newUrl));

        expect(await oldFile.exists(), isFalse);
        expect(await newFile.exists(), isTrue);
      },
    );
  });
}
