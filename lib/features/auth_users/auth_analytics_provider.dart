import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/management_api.dart';
import '../../core/providers/core_providers.dart';
import '../../core/providers/analytics_providers.dart';

final authStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  
  // Query 1: User Growth over last 30 days
  final growthQuery = '''
    SELECT 
      date_trunc('day', created_at)::date as date, 
      count(*) as count 
    FROM auth.users 
    WHERE created_at > now() - interval '30 days'
    GROUP BY 1 
    ORDER BY 1;
  ''';
  
  // Query 2: Users by Confirmation Status
  final statusQuery = '''
    SELECT 
      CASE WHEN confirmed_at IS NOT NULL THEN 'Confirmed' ELSE 'Unconfirmed' END as status,
      count(*) as count
    FROM auth.users
    GROUP BY 1;
  ''';

  final growthData = await api.runQuery(projectRef, growthQuery);
  final statusData = await api.runQuery(projectRef, statusQuery);

  return {
    'growth': growthData,
    'status': statusData,
  };
});
