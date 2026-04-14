// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.nickname,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  // 从 JSON 转换
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // 复制方法，用于更新
  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 获取显示名称
  String get displayName {
    return nickname ?? '预言家${id.substring(0, 8)}';
  }
}