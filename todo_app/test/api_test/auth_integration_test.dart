@Tags(['integration'])
@Skip('Requires backend server; skipped in CI')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/api/auth.dart';
import 'package:todo_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('AuthService Integration Tests', () {
    late AuthService authService;

    setUpAll(() async {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        print('Note: .env file not found, using default URL');
      }
      authService = AuthService();
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('Signup', () {
      test(
        'successful signup returns AuthResult with user but not verified',
        () async {
          final user = User(
            email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
            username: 'testuser${DateTime.now().millisecondsSinceEpoch}',
            password: 'password123',
          );

          final result = await authService.signup(user);

          expect(result.success, isTrue);
          expect(result.user, isNotNull);
          expect(result.user!.email, user.email);
          expect(result.user!.username, user.username);
          expect(
            result.user!.is_verified,
            isFalse,
          ); // Should not be verified after signup
          expect(result.message, contains('User created'));

          // Verify token was saved
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('access_token'), isNotNull);
        },
      );

      test('duplicate email returns failure', () async {
        final user = User(
          email: 'duplicate@example.com',
          username: 'duplicateuser',
          password: 'password123',
        );

        // First signup should succeed
        await authService.signup(user);

        // Second signup with same email should fail
        final result = await authService.signup(user);

        expect(result.success, isFalse);
        expect(result.user, isNull);
        expect(result.message, isNotEmpty);
      });

      test('invalid data returns failure', () async {
        final user = User(
          email: 'invalid-email',
          username: '',
          password: '123',
        );

        final result = await authService.signup(user);

        expect(result.success, isFalse);
        expect(result.user, isNull);
        expect(result.message, isNotEmpty);
      });
    });

    group('Login', () {
      test(
        'successful login returns AuthResult with user and respects verification status',
        () async {
          // First signup a user
          final user = User(
            email: 'login${DateTime.now().millisecondsSinceEpoch}@example.com',
            username: 'loginuser${DateTime.now().millisecondsSinceEpoch}',
            password: 'password123',
          );
          await authService.signup(user);

          // Then login
          final result = await authService.login(user.email, user.password!);

          expect(result.success, isTrue);
          expect(result.user, isNotNull);
          expect(result.user!.email, user.email);
          expect(
            result.user!.is_verified,
            isFalse,
          ); // Should match server response
          expect(result.message, contains('verify your email'));

          // Verify token was saved
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('access_token'), isNotNull);
        },
      );

      test('wrong password returns failure', () async {
        final result = await authService.login(
          'test@example.com',
          'wrongpassword',
        );

        expect(result.success, isFalse);
        expect(result.user, isNull);
        expect(result.message, isNotEmpty);
      });

      test('nonexistent user returns failure', () async {
        final result = await authService.login(
          'nonexistent@example.com',
          'password123',
        );

        expect(result.success, isFalse);
        expect(result.user, isNull);
        expect(result.message, isNotEmpty);
      });
    });

    group('Verify', () {
      test(
        'successful verification returns AuthResult with verified user',
        () async {
          final email =
              'verify${DateTime.now().millisecondsSinceEpoch}@example.com';
          final user = User(
            email: email,
            username: 'verifyuser${DateTime.now().millisecondsSinceEpoch}',
            password: 'password123',
          );

          // Signup first
          await authService.signup(user);

          // Verify with a mock code (this would normally come from email)
          final result = await authService.verify(email, '123456');

          expect(result.success, isTrue);
          expect(result.user, isNotNull);
          expect(result.user!.email, email);
          expect(result.user!.is_verified, isTrue);
          expect(result.message, 'Email verified successfully!');

          // Verify token was saved
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('access_token'), isNotNull);
        },
      );

      test('invalid verification code returns failure', () async {
        final email =
            'verifyfail${DateTime.now().millisecondsSinceEpoch}@example.com';
        final user = User(
          email: email,
          username: 'verifyfailuser${DateTime.now().millisecondsSinceEpoch}',
          password: 'password123',
        );

        // Signup first
        await authService.signup(user);

        // Try to verify with wrong code
        final result = await authService.verify(email, '000000');

        expect(result.success, isFalse);
        expect(result.user, isNull);
        expect(result.message, isNotEmpty);
      });

      test('verification for nonexistent email returns failure', () async {
        final result = await authService.verify(
          'nonexistent@example.com',
          '123456',
        );

        expect(result.success, isFalse);
        expect(result.user, isNull);
        expect(result.message, isNotEmpty);
      });
    });
  });
}
