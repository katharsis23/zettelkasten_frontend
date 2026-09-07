@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/api/auth.dart';
import 'package:todo_app/models/user.dart';

void main() {
  group('AuthService Unit Tests', () {
    group('AuthResult', () {
      test('AuthResult constructor works correctly', () {
        final user = User(email: 'test@example.com', username: 'test');
        final result = AuthResult(
          success: true,
          message: 'Success',
          user: user,
        );

        expect(result.success, isTrue);
        expect(result.message, 'Success');
        expect(result.user, user);
      });

      test('AuthResult constructor works without user', () {
        final result = AuthResult(success: false, message: 'Failure');

        expect(result.success, isFalse);
        expect(result.message, 'Failure');
        expect(result.user, isNull);
      });
    });
  });
}
