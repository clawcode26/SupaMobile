import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/core_providers.dart';
import '../../core/providers/analytics_providers.dart';
import '../../core/api/management_api.dart';

final indexesProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  final query = '''
    SELECT schemaname, tablename, indexname, indexdef
    FROM pg_indexes
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY schemaname, tablename, indexname;
  ''';
  return await api.runQuery(projectRef, query);
});

final triggersProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  final query = '''
    SELECT 
      event_object_schema as schema_name,
      event_object_table as table_name,
      trigger_name,
      event_manipulation as event,
      action_timing as timing,
      action_statement as definition
    FROM information_schema.triggers
    ORDER BY schema_name, table_name, trigger_name;
  ''';
  return await api.runQuery(projectRef, query);
});

final publicationsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  final query = '''
    SELECT pubname, puballtables, pubinsert, pubupdate, pubdelete 
    FROM pg_publication;
  ''';
  return await api.runQuery(projectRef, query);
});
final databaseFunctionsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  final query = '''
    SELECT 
      n.nspname as schema_name,
      p.proname as function_name,
      pg_get_function_arguments(p.oid) as arguments,
      pg_get_function_result(p.oid) as result_type,
      CASE 
        WHEN p.prorettype = 'trigger'::regtype THEN 'trigger'
        ELSE 'function'
      END as type
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY schema_name, function_name;
  ''';
  return await api.runQuery(projectRef, query);
});

final authProvidersProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  final query = '''
    SELECT 
      provider, 
      count(*) as user_count 
    FROM auth.identities 
    GROUP BY provider;
  ''';
  return await api.runQuery(projectRef, query);
});

