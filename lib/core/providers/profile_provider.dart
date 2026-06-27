import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final bool isPro;
  final List<String> favoriteProjects;

  UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.isPro = false,
    this.favoriteProjects = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      isPro: json['is_pro'] ?? false,
      favoriteProjects: List<String>.from(json['favorite_projects'] ?? []),
    );
  }
}

// Local mock profile
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return Stream.value(UserProfile(id: 'local-user', fullName: 'Local Developer', isPro: true));
});

