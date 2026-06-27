import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/management_api.dart';
import '../../core/providers/core_providers.dart';

import '../../core/providers/analytics_providers.dart';

final projectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(managementApiProvider);
  return api.getProjects();
});

