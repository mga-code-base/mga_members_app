import 'dart:convert';
import '../core/network/api_client.dart';

class ChatApiService {
  static final ApiClient _client = ApiClient();

  static Future<String?> askTrainerBot({
    required String message,
    required String mode,
  }) async {
    final Map<String, String> bodyData = {
      "message": message,
      "mode": mode.toLowerCase(),
      "sessionId": "user-session-123",
    };

    try {
      final response = await _client.post('/chat', body: bodyData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['response'];
      }
    } catch (_) {}
    return null;
  }
}
