import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/trainer_model.dart';
import 'auth_cache_service.dart';

class PeopleApiService {
  static final ApiClient _client = ApiClient();

  static Future<bool> signup(Map<String, String> data) async {
    try {
      final response = await _client.post('/members', body: data, auth: false);
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
    final Map<String, String> bodyData = {
      'username': username,
      'password': password,
    };

    try {
      final response = await _client.post('/members/login', body: bodyData, auth: false).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final String? extractedToken = data['secureToken'] ?? data['token'] ?? data['accessToken'];

          await AuthCacheService.saveSessionCache(
            username: username,
            memberId: data['memberId'],
            token: extractedToken,
            trainerId: data['trainerId'],
            isActive: data['isActive'],
            isFacialRegCompleted: data['isFacialRegCompleted'],
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<TrainerModel?> fetchTrainerDetails(String trainerId) async {
    try {
      final response = await _client.get('/trainers/$trainerId').timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return TrainerModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }
}
