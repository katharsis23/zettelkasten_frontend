@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/api/healthcheck.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Note: .env file not found, using default URL');
    }
  });

  group('Healthcheck Integration Test (REAL NETWORK)', () {
    test('Actual server connectivity test', () async {
      final result = await check_server_health();

      if (!result) {
        print(' SERVER IS DOWN! Test failed as expected by Master <3');
      } else {
        print('SERVER IS UP! Everything is fine!');
      }

      expect(
        result,
        isTrue,
        reason: 'The server is unreachable. Please start your backend!',
      );
    });
  });
}
