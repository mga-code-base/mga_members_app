import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/branch_model.dart';
import '../models/workout_model.dart';
import '../models/grievance_model.dart';

class ResourceApiService {
  static final ApiClient _client = ApiClient();

  static Future<List<BranchItem>> fetchAllBranches() async {
    try {
      final response = await _client.get('/branch/all').timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return BranchResponse.fromJson(jsonDecode(response.body)).allBranches;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, String>>> fetchAllBranchNames() async {
    try {
      final response = await _client.get('/branch/allbranchnames');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('allBrancheNames') && data['allBrancheNames'] is Map) {
          final Map<String, dynamic> branchMap = data['allBrancheNames'];
          List<Map<String, String>> structuralList = [];
          branchMap.forEach((key, value) {
            structuralList.add({
              'id': key.toString(),
              'name': value.toString(),
            });
          });
          return structuralList;
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load Branch names: ${e.toString()}');
    }
  }

  static Future<List<String>> fetchExercises(String targetMuscle) async {
    final lowerMuscle = targetMuscle.toLowerCase();
    try {
      final response = await _client.get('/workouts/$lowerMuscle');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return List<String>.from(data['allExcercises'] ?? []);
      }
      throw Exception('Failed to load exercises for $targetMuscle');
    } catch (e) {
      throw Exception('Exercise sync pipeline exception: ${e.toString()}');
    }
  }

  static Future<List<String>> fetchExercisesByMuscle(String muscle) async {
    try {
      final response = await _client.get('/exercises', query: {'muscle': muscle});

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => item.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<ProgressRecords?> fetchProgressReport(String memberId) async {
    try {
      final response = await _client.get('/my-records/progress', query: {'memberId': memberId});

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body);
        if (rawJson['memberId'] == -1 || rawJson['memberId'] == '-1') return null;
        return ProgressRecords.fromJson(rawJson);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> createWorkoutRecord(Map<String, dynamic> recordPayload) async {
    try {
      final response = await _client.post('/my-records', body: recordPayload);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchPreviousRecords({
    required int memberId,
    required String targetMuscle,
    required String exerciseName,
  }) async {
    try {
      final response = await _client.get(
        '/my-records/previous',
        query: {'memberId': memberId.toString(), 'targetMuscle': targetMuscle, 'exerciseName': exerciseName},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch previous logs');
    } catch (e) {
      throw Exception('History query failure: ${e.toString()}');
    }
  }

  Future<List<Grievance>> fetchActiveGrievances(String memberId) async {
    try {
      final response = await _client.get('/grievances/allactive/member/$memberId');

      if (response.statusCode == 200) {
        return _parseGrievanceList(jsonDecode(response.body), 'activeGrievances');
      }
      throw Exception('Failed to pull active grievances payload data from server.');
    } catch (e) {
      return [];
    }
  }

  Future<List<Grievance>> fetchInactiveGrievances(String memberId) async {
    try {
      final response = await _client.get('/grievances/allinactive/member/$memberId');

      if (response.statusCode == 200) {
        return _parseGrievanceList(jsonDecode(response.body), 'inactiveGrievances');
      }
      throw Exception('Failed to pull inactive ticket metrics archive history.');
    } catch (e) {
      return [];
    }
  }

  List<Grievance> _parseGrievanceList(dynamic decodedData, String primaryKey) {
    if (decodedData is Map<String, dynamic>) {
      final List<dynamic> list = decodedData[primaryKey] ??
          decodedData['content'] ??
          decodedData['allGrievances'] ??
          decodedData.values.firstWhere((v) => v is List, orElse: () => []);
      return list.map((dynamic item) => Grievance.fromJson(item)).toList();
    }
    if (decodedData is List) {
      return decodedData.map((dynamic item) => Grievance.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> createGrievance(Grievance grievance) async {
    try {
      final response = await _client.post('/grievances', body: grievance.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Network exception encountered while submitting payload: ${e.toString()}');
    }
  }
}
