import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectApi {
  final String projectRef;
  final String serviceRoleKey;

  ProjectApi({required this.projectRef, required this.serviceRoleKey});

  String get _baseUrl => 'https://$projectRef.supabase.co';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $serviceRoleKey',
        'apiKey': serviceRoleKey,
        'Content-Type': 'application/json',
      };

  Future<List<dynamic>> getAuthUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/v1/admin/users'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['users'] as List<dynamic>;
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  Future<List<dynamic>> getStorageBuckets() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/storage/v1/bucket'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load buckets: ${response.body}');
    }
  }

  Future<List<dynamic>> getStorageObjects(String bucketId, {String path = ''}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/storage/v1/object/list/$bucketId'),
      headers: _headers,
      body: jsonEncode({
        'prefix': path,
        'limit': 100,
        'offset': 0,
        'sortBy': {'column': 'name', 'order': 'asc'}
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load storage objects: ${response.body}');
    }
  }

  Future<List<dynamic>> getTableData(String tableName, {int limit = 100}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/rest/v1/$tableName?select=*&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load table data: ${response.body}');
    }
  }

  Future<void> updateRow(String tableName, String pkCol, dynamic pkVal, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/rest/v1/$tableName?$pkCol=eq.$pkVal'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode >= 300) {
      throw Exception('Update failed: ${response.body}');
    }
  }

  Future<void> deleteRow(String tableName, String pkCol, dynamic pkVal) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/rest/v1/$tableName?$pkCol=eq.$pkVal'),
      headers: _headers,
    );

    if (response.statusCode >= 300) {
      throw Exception('Delete failed: ${response.body}');
    }
  }

  Future<void> insertRow(String tableName, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/rest/v1/$tableName'),
      headers: {
        ..._headers,
        'Prefer': 'return=representation',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 300) {
      throw Exception('Insert failed: ${response.body}');
    }
  }
}

