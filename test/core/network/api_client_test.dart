import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mga_members_app/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient — request construction', () {
    late http.Request captured;

    ApiClient buildClient(http.Response response, {String? baseUrl}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return response;
      });
      return ApiClient(baseUrl: baseUrl, client: mockClient);
    }

    test('GET builds the correct default base URL', () async {
      final client = buildClient(http.Response('{}', 200));
      await client.get('/branch/all');

      expect(captured.method, 'GET');
      expect(captured.url.toString(), 'https://api.06071995.xyz/api/branch/all');
    });

    test('a custom baseUrl overrides the default (used by PostureApiService)', () async {
      final client = buildClient(http.Response('{}', 200), baseUrl: 'https://custom.example.com');
      await client.get('/analyze/squat');

      expect(captured.url.toString(), 'https://custom.example.com/analyze/squat');
    });

    test('GET with query parameters appends them to the URL', () async {
      final client = buildClient(http.Response('{}', 200));
      await client.get('/my-records/progress', query: {'memberId': '55'});

      expect(captured.url.queryParameters['memberId'], '55');
    });

    test('POST with a body JSON-encodes it', () async {
      final client = buildClient(http.Response('{}', 201));
      await client.post('/members', body: {'username': 'bob'});

      expect(captured.method, 'POST');
      expect(captured.body, '{"username":"bob"}');
    });

    test('POST with auth:false sends no Authorization header even if a token is cached', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'some-token',
        'token_issued_at': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      final client = buildClient(http.Response('{}', 200));
      await client.post('/members/login', body: {'username': 'bob'}, auth: false);

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });

    test('DELETE hits the right path with no body', () async {
      final client = buildClient(http.Response('', 200));
      await client.delete('/grievances/5');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/api/grievances/5');
    });

    test('the raw http.Response is returned untouched', () async {
      final client = buildClient(http.Response('{"ok":true}', 201));
      final response = await client.get('/branch/all');

      expect(response.statusCode, 201);
      expect(response.body, '{"ok":true}');
    });
  });

  group('ApiClient — auth header injection', () {
    test('injects a Bearer token when one is cached and valid', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'test-token-123',
        'token_issued_at': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.get('/branch/all');

      expect(captured.headers['Authorization'], 'Bearer test-token-123');
    });

    test('sends no Authorization header when no token is cached', () async {
      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.get('/branch/all');

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });

    test('an expired cached token (>30 min old) is not sent', () async {
      SharedPreferences.setMockInitialValues({
        'secureToken': 'stale-token',
        'token_issued_at': DateTime.now().subtract(const Duration(minutes: 31)).millisecondsSinceEpoch.toString(),
      });

      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(client: mockClient);

      await client.get('/branch/all');

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });
  });
}
