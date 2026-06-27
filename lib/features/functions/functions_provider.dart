import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/management_api.dart';
import '../../core/providers/core_providers.dart';

import '../../core/providers/analytics_providers.dart';

final edgeFunctionsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  return api.getFunctions(projectRef);
});

final secretsProvider = FutureProvider.family<List<dynamic>, String>((ref, projectRef) async {
  final api = ref.watch(managementApiProvider);
  return api.getSecrets(projectRef);
});

