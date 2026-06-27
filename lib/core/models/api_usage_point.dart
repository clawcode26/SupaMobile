class ApiUsagePoint {
  final DateTime timestamp;
  final int dbRequests;       // total_rest_requests
  final int authRequests;     // total_auth_requests
  final int storageRequests;  // total_storage_requests
  final int realtimeRequests; // total_realtime_requests

  ApiUsagePoint({
    required this.timestamp,
    required this.dbRequests,
    required this.authRequests,
    required this.storageRequests,
    required this.realtimeRequests,
  });

  int get totalRequests =>
      dbRequests + authRequests + storageRequests + realtimeRequests;

  factory ApiUsagePoint.fromJson(Map<String, dynamic> json) {
    return ApiUsagePoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      dbRequests: (json['total_rest_requests'] as num?)?.toInt() ?? 0,
      authRequests: (json['total_auth_requests'] as num?)?.toInt() ?? 0,
      storageRequests: (json['total_storage_requests'] as num?)?.toInt() ?? 0,
      realtimeRequests: (json['total_realtime_requests'] as num?)?.toInt() ?? 0,
    );
  }
}
