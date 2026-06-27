import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/analytics_api.dart';
import '../api/management_api_client.dart';
import '../api/project_api_client.dart';
import '../api/management_api.dart';
import 'core_providers.dart';

// Enum for the time range selector
enum MetricTimeRange { hour, day, week, month }

// Selected time range state
class MetricTimeRangeNotifier extends Notifier<MetricTimeRange> {
  @override
  MetricTimeRange build() => MetricTimeRange.week;

  void set(MetricTimeRange val) => state = val;
}

final metricTimeRangeProvider = NotifierProvider<MetricTimeRangeNotifier, MetricTimeRange>(MetricTimeRangeNotifier.new);

// Analytics API instance
final analyticsApiProvider = Provider<AnalyticsApi>((ref) {
  final pat = ref.watch(patProvider).asData?.value;
  return AnalyticsApi(
    client: ManagementApiClient(pat: pat ?? ''),
  );
});

// Management API instance (parallel-aware)
final managementApiProvider = Provider<ManagementApi>((ref) {
  final pat = ref.watch(patProvider).asData?.value;
  return ManagementApi(
    client: ManagementApiClient(pat: pat ?? ''),
  );
});

// Project-specific Admin API client
final projectApiClientProvider = Provider.family<ProjectApiClient, String>((ref, projectRef) {
  final serviceKey = ref.watch(serviceRoleKeyProvider(projectRef)).asData?.value;
  return ProjectApiClient(
    projectRef: projectRef,
    serviceRoleKey: serviceKey ?? '',
  );
});
