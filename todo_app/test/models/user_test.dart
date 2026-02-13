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

    test('send_login_data returns correct map', () {
      final user = User(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
      );
      final data = user.send_login_data();

      expect(data['email'], 'test@example.com');
      expect(data['username'], 'testuser');
      expect(data['password'], 'password123');
    });

    test('set_avatar updates avatar_url', () {
      final user = User(email: 'a@b.com', username: 'u');
      user.set_avatar('new_url');
      expect(user.avatar_url, 'new_url');
    });

    group('Token Caching & Verification', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('check_verified sets is_verified to true if token exists', () async {
        final user = User(email: 'a@b.com', username: 'u');
        expect(user.is_verified, isFalse);

        // Manually set token in mock preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', 'fake_token');

        await user.check_verified();
        expect(user.is_verified, isTrue);
      });

      test('check_verified keeps is_verified false if token missing', () async {
        final user = User(email: 'a@b.com', username: 'u');
        await user.check_verified();
        expect(user.is_verified, isFalse);
      });

      test('set_access_token_and_set_is_verified works correctly', () async {
        final user = User(email: 'a@b.com', username: 'u');
        await user.set_access_token_and_set_is_verified('new_token');

        expect(user.is_verified, isTrue);

        // Verify it's actually in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('access_token'), 'new_token');
      });
    });
  });
}
