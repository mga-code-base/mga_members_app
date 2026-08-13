import 'package:shared_preferences/shared_preferences.dart';

class AuthCacheService {
  static const Duration _tokenTtl = Duration(minutes: 30);

  static Future<void> saveSessionCache({
    required String username,
    required dynamic memberId,
    required String? token,
    required String? trainerId,
    required bool? isActive,
    required bool? isFacialRegCompleted,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('secureToken', token ?? '');
    await prefs.setString('token_issued_at', DateTime.now().millisecondsSinceEpoch.toString());

    if (memberId != null) {
      await prefs.setString('memberId', memberId.toString());
    }
    if (trainerId != null) {
      await prefs.setString('trainerId', trainerId.toString());
    }
    if (isActive != null) {
      await prefs.setBool('isActive', isActive);
    }
    if (isFacialRegCompleted != null) {
      await prefs.setBool('isFacialRegCompleted', isFacialRegCompleted);
    }
  }

  static Future<bool> _isTokenExpired() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? issuedAtRaw = prefs.getString('token_issued_at');
    if (issuedAtRaw == null) return false;
    final int? issuedAtMillis = int.tryParse(issuedAtRaw);
    if (issuedAtMillis == null) return false;
    final DateTime issuedAt = DateTime.fromMillisecondsSinceEpoch(issuedAtMillis);
    return DateTime.now().difference(issuedAt) > _tokenTtl;
  }

  static Future<String?> getValidToken() async {
    if (await _isTokenExpired()) {
      await clearSessionCache();
      return null;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('secureToken');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final String? token = await getValidToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> getAdminToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('secureToken');
  }

  static Future<String?> getCachedMemberId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('memberId');
  }

  static Future<String?> getCachedToken() async {
    return getValidToken();
  }

  static Future<String?> getCachedUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<String?> getCachedTrainerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('trainerId');
  }

  static Future<bool?> getIsActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isActive');
  }

  static Future<bool?> getIsFacialRegCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFacialRegCompleted');
  }

  static Future<void> clearSessionCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
