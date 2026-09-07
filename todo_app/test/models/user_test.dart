import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/user.dart';

void main() {
  group('User Model', () {
    test('fromJson creates a user correctly', () {
      final json = {
        'email': 'test@example.com',
        'username': 'testuser',
        'avatar_url': 'http://image.com/avatar.png',
      };
      final user = User.fromJson(json);

      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
      expect(user.avatar_url, 'http://image.com/avatar.png');
    });

    test('toJson returns correct map', () {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
        avatar_url: 'http://image.com/avatar.png',
      );
      final json = user.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['username'], 'testuser');
      expect(json['password'], 'password123');
      expect(json['avatar_url'], 'http://image.com/avatar.png');
    });

    test('sendLoginData returns correct map', () {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
      );
      final data = user.sendLoginData();

      expect(data['email'], 'test@example.com');
      expect(data['password'], 'password123');
      expect(data.length, 2); // Should only contain email and password
    });

    test('sendSignupData returns correct map', () {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
      );
      final data = user.sendSignupData();

      expect(data['email'], 'test@example.com');
      expect(data['username'], 'testuser');
      expect(data['password'], 'password123');
      expect(data.length, 3); // Should contain email, username, and password
    });

    group('Token Caching & Verification', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test(
        'saveToken saves token without changing verification status',
        () async {
          final user = User(email: 'a@b.com', username: 'u');
          expect(user.is_verified, isFalse);

          await user.saveToken('test_token');

          expect(user.is_verified, isFalse); // Should remain false

          // Verify it's actually in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('access_token'), 'test_token');
        },
      );

      test(
        'saveTokenAndVerify saves token and sets is_verified to true',
        () async {
          final user = User(email: 'a@b.com', username: 'u');
          expect(user.is_verified, isFalse);

          await user.saveTokenAndVerify('test_token');

          expect(user.is_verified, isTrue);

          // Verify it's actually in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('access_token'), 'test_token');
        },
      );

      test('fromJson handles is_verified field correctly', () {
        final json = {
          'email': 'test@example.com',
          'username': 'testuser',
          'is_verified': true,
        };
        final user = User.fromJson(json);

        expect(user.is_verified, isTrue);
      });

      test('fromJson defaults is_verified to false when not provided', () {
        final json = {'email': 'test@example.com', 'username': 'testuser'};
        final user = User.fromJson(json);

        expect(user.is_verified, isFalse);
      });
    });
  });
}
