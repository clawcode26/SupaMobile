import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectApiClient {
  final String projectRef;
  final String serviceRoleKey;

  ProjectApiClient({
    required this.projectRef,
    required this.serviceRoleKey,
  });

  String get _baseUrl => 'https://$projectRef.supabase.co';

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $serviceRoleKey',
    'apikey': serviceRoleKey,
    'Content-Type': 'application/json',
  };

  /// Returns total user count WITHOUT fetching all users.
  /// Reads the X-Total-Count response header.
  Future<int> getAuthUserCount() async {
    final uri = Uri.parse('$_baseUrl/auth/v1/admin/users?per_page=1&page=1');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch auth users: ${response.statusCode}');
    }

    final totalCount = response.headers['x-total-count'];
    if (totalCount != null) {
      return int.tryParse(totalCount) ?? 0;
    }

    final body = jsonDecode(response.body);
    final users = body['users'] as List<dynamic>? ?? body as List<dynamic>? ?? [];
    return users.length;
  }

  /// Fetch paginated users
  Future<Map<String, dynamic>> getAuthUsers({
    int page = 1,
    int perPage = 50,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/auth/v1/admin/users?per_page=$perPage&page=$page',
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch auth users: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final totalCount = int.tryParse(
      response.headers['x-total-count'] ?? '0',
    ) ?? 0;

    return {
      'users': body['users'] ?? body,
      'total': totalCount,
    };
  }
}
