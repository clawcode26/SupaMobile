class Project {
  final String id;
  final String ref;
  final String name;
  final String organizationId;
  final String status;
  final String region;

  Project({
    required this.id,
    required this.ref,
    required this.name,
    required this.organizationId,
    required this.status,
    required this.region,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      ref: json['ref'] ?? '',
      name: json['name'] ?? '',
      organizationId: json['organization_id'] ?? '',
      status: json['status'] ?? '',
      region: json['region'] ?? '',
    );
  }
}

