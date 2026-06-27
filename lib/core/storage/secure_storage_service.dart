import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  
  static const _patKey = 'supabase_pat';
  static const _serviceKeyPrefix = 'supabase_service_key_';
  static const _anonKeyPrefix = 'supabase_anon_key_';
  static const _sqlSnippetsKey = 'supabase_sql_snippets';
  static const _biometricsKey = 'supabase_biometrics_enabled';

  // PAT
  Future<void> savePAT(String pat) async {
    await _storage.write(key: _patKey, value: pat);
  }

  Future<String?> getPAT() async {
    return await _storage.read(key: _patKey);
  }

  Future<void> deletePAT() async {
    await _storage.delete(key: _patKey);
  }

  // Service Role Key (Per Project)
  Future<void> saveServiceKey(String projectRef, String key) async {
    await _storage.write(key: '$_serviceKeyPrefix$projectRef', value: key);
  }

  Future<String?> getServiceKey(String projectRef) async {
    return await _storage.read(key: '$_serviceKeyPrefix$projectRef');
  }

  // Anon Key (Per Project)
  Future<void> saveAnonKey(String projectRef, String key) async {
    await _storage.write(key: '$_anonKeyPrefix$projectRef', value: key);
  }

  Future<String?> getAnonKey(String projectRef) async {
    return await _storage.read(key: '$_anonKeyPrefix$projectRef');
  }

  // SQL Snippets (JSON stored as string)
  Future<void> saveSqlSnippet(String name, String query) async {
    final Map<String, String> snippets = await getSqlSnippets();
    snippets[name] = query;
    await _storage.write(key: _sqlSnippetsKey, value: jsonEncode(snippets));
  }

  Future<Map<String, String>> getSqlSnippets() async {
    final data = await _storage.read(key: _sqlSnippetsKey);
    if (data == null) return {};
    return Map<String, String>.from(jsonDecode(data));
  }

  Future<void> deleteSqlSnippet(String name) async {
    final Map<String, String> snippets = await getSqlSnippets();
    snippets.remove(name);
    await _storage.write(key: _sqlSnippetsKey, value: jsonEncode(snippets));
  }

  // Biometrics
  Future<bool> isBiometricsEnabled() async {
    final value = await _storage.read(key: _biometricsKey);
    return value == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _biometricsKey, value: enabled.toString());
  }
}
