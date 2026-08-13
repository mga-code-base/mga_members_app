import 'package:flutter_test/flutter_test.dart';
import 'package:mga_members_app/services/auth_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('saveSessionCache / getValidToken', () {
    test('a freshly saved session returns its token', () async {
      await AuthCacheService.saveSessionCache(
        username: 'bob',
        memberId: 'M-1',
        token: 'fresh-token',
        trainerId: 'T-1',
        isActive: true,
        isFacialRegCompleted: false,
      );

      expect(await AuthCacheService.getValidToken(), 'fresh-token');
    });

    test('a token cached less than 30 minutes ago is still valid', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'still-good',
        'token_issued_at': DateTime.now().subtract(const Duration(minutes: 20)).millisecondsSinceEpoch.toString(),
      });

      expect(await AuthCacheService.getValidToken(), 'still-good');
    });

    test('a token cached more than 30 minutes ago is expired and cleared', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'stale',
        'token_issued_at': DateTime.now().subtract(const Duration(minutes: 31)).millisecondsSinceEpoch.toString(),
        'username': 'bob',
      });

      expect(await AuthCacheService.getValidToken(), isNull);
      expect(await AuthCacheService.getCachedUsername(), isNull);
    });

    test('a token exactly at the boundary is treated as expired', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'boundary',
        'token_issued_at': DateTime.now().subtract(const Duration(minutes: 30, seconds: 1)).millisecondsSinceEpoch.toString(),
      });

      expect(await AuthCacheService.getValidToken(), isNull);
    });

    test('a token with no issued-at timestamp is treated as not expired', () async {
      SharedPreferences.setMockInitialValues({'secureToken': 'legacy-token'});
      expect(await AuthCacheService.getValidToken(), 'legacy-token');
    });

    test('no cached session at all returns null', () async {
      expect(await AuthCacheService.getValidToken(), isNull);
    });
  });

  group('getAuthHeaders', () {
    test('includes a Bearer token when one is valid', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'my-token',
        'token_issued_at': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final headers = await AuthCacheService.getAuthHeaders();
      expect(headers['Authorization'], 'Bearer my-token');
    });

    test('omits Authorization when the token is expired', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'my-token',
        'token_issued_at': DateTime.now().subtract(const Duration(minutes: 45)).millisecondsSinceEpoch.toString(),
      });

      final headers = await AuthCacheService.getAuthHeaders();
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('clearSessionCache', () {
    test('wipes every cached session value', () async {
      await AuthCacheService.saveSessionCache(
        username: 'bob',
        memberId: 'M-1',
        token: 't',
        trainerId: 'T-1',
        isActive: true,
        isFacialRegCompleted: true,
      );

      await AuthCacheService.clearSessionCache();

      expect(await AuthCacheService.getCachedUsername(), isNull);
      expect(await AuthCacheService.getCachedMemberId(), isNull);
      expect(await AuthCacheService.getCachedTrainerId(), isNull);
      expect(await AuthCacheService.getValidToken(), isNull);
    });
  });

  group('getIsActive / getIsFacialRegCompleted', () {
    test('return the saved boolean values', () async {
      await AuthCacheService.saveSessionCache(
        username: 'bob',
        memberId: 'M-1',
        token: 't',
        trainerId: null,
        isActive: true,
        isFacialRegCompleted: false,
      );

      expect(await AuthCacheService.getIsActive(), isTrue);
      expect(await AuthCacheService.getIsFacialRegCompleted(), isFalse);
    });

    test('return null when never saved', () async {
      expect(await AuthCacheService.getIsActive(), isNull);
      expect(await AuthCacheService.getIsFacialRegCompleted(), isNull);
    });
  });
}
