import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import 'management_api_client.dart';

class ManagementApi {
  final ManagementApiClient _client;

  ManagementApi({required ManagementApiClient client}) : _client = client;

  Future<List<Project>> getProjects() async {
    final List<dynamic> data = await _client.get('/projects');
    return data.map((json) => Project.fromJson(json)).toList();
  }

  Future<Map<String, String>> getApiKeys(String projectRef) async {
    final List<dynamic> data = await _client.get('/projects/$projectRef/api-keys');
    
    String anonKey = '';
    String serviceRoleKey = '';
    
    for (var keyObj in data) {
      if (keyObj['name'] == 'anon' || keyObj['tags'] == 'anon') {
        anonKey = keyObj['api_key'] ?? '';
      } else if (keyObj['name'] == 'service_role' || keyObj['tags'] == 'service_role') {
        serviceRoleKey = keyObj['api_key'] ?? '';
      }
    }
    
    return {
      'anon': anonKey,
      'service_role': serviceRoleKey,
    };
  }

  Future<Map<String, dynamic>> getAllUsage(String projectRef, {String interval = '7d'}) async {
    final results = await Future.wait([
      _client.get('/projects/$projectRef/analytics/endpoints/usage.api-counts', queryParams: {'interval': interval}),
      _client.get('/projects/$projectRef/analytics/endpoints/usage.api-requests-count', queryParams: {'interval': interval}),
    ]);

    return {
      'api_counts': (results[0] as Map<String, dynamic>)['result'] ?? [],
      'summary_count': (results[1] as Map<String, dynamic>)['result'] ?? [],
    };
  }

  Future<Map<String, dynamic>> getOrgUsage(String orgSlug) async {
    final dynamic data = await _client.get('/organizations/$orgSlug/usage');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, double>> getHostMetrics(String projectRef, String serviceRoleKey) async {
    final response = await http.get(
      Uri.parse('https://$projectRef.supabase.co/customer/v1/privileged/metrics'),
      headers: {
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
    );

    if (response.statusCode == 200) {
      return _parsePrometheus(response.body);
    }
    return {};
  }

  Future<int> getAuthUserCount(String projectRef, String serviceRoleKey) async {
    final response = await http.get(
      Uri.parse('https://$projectRef.supabase.co/auth/v1/admin/users?page=1&per_page=1'),
      headers: {
        'Authorization': 'Bearer $serviceRoleKey',
        'apikey': serviceRoleKey,
      },
    );

    if (response.statusCode == 200) {
      final count = response.headers['x-total-count'];
      return int.tryParse(count ?? '0') ?? 0;
    }
    return 0;
  }

  Map<String, double> _parsePrometheus(String data) {
    final Map<String, double> metrics = {};
    final lines = data.split('\n');
    for (var line in lines) {
      if (line.startsWith('#') || line.trim().isEmpty) continue;
      final parts = line.split(' ');
      if (parts.length >= 2) {
        final name = parts[0].split('{')[0];
        final value = double.tryParse(parts[1]);
        if (value != null) metrics[name] = value;
      }
    }
    return metrics;
  }

  Future<List<dynamic>> runLogQuery(String projectRef, String sql) async {
    final Map<String, dynamic> data = await _client.get(
      '/projects/$projectRef/analytics/endpoints/logs.all',
      queryParams: {'sql': sql},
    );
    return data['result'] ?? [];
  }

  Future<List<dynamic>> getFunctions(String projectRef) async {
    final dynamic data = await _client.get('/projects/$projectRef/functions');
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getSecrets(String projectRef) async {
    final dynamic data = await _client.get('/projects/$projectRef/secrets');
    return data as List<dynamic>;
  }

  Future<List<dynamic>> runQuery(String projectRef, String query) async {
    final dynamic data = await _client.post('/projects/$projectRef/database/query', body: {'query': query});
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getLogs(String projectRef, String collection, {String? query}) async {
    final params = {'collection': collection};
    if (query != null) params['query'] = query;
    
    final Map<String, dynamic> data = await _client.get('/projects/$projectRef/logs', queryParams: params);
    return data['result'] ?? [];
  }
}
