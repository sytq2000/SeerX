// lib/models/app_user.dart
class AppUser {
  final String id;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.id,
    required this.email,
    this.nickname,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    return nickname ?? '预言家${id.substring(0, 8)}';
  }
}