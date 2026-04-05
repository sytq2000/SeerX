// lib/models/prediction.dart
class Prediction {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime dueDate;
  final String status;
  final bool? isSuccess;
  final DateTime? judgedAt;
  
  // ========== V0.5 新增：标签字段 ==========
  final String? tag; // 标签（可空，兼容旧数据）
  // ========================================
  
  Prediction({
    required this.id,
    required this.content,
    required this.dueDate,
    this.status = 'pending',
    this.isSuccess,
    this.judgedAt,
    this.tag, // 新增参数
  }) : createdAt = DateTime.now();
  
  // 创建一个更新状态的副本
  Prediction copyWith({
    String? status,
    bool? isSuccess,
    DateTime? judgedAt,
    String? tag, // 新增：支持更新标签
  }) {
    return Prediction(
      id: id,
      content: content,
      dueDate: dueDate,
      status: status ?? this.status,
      isSuccess: isSuccess ?? this.isSuccess,
      judgedAt: judgedAt ?? this.judgedAt,
      tag: tag ?? this.tag, // 复制标签
    );
  }

  // === 数据持久化支持 ===
  
  /// 将 Prediction 对象转换为 Map（可用于转换为JSON字符串）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'isSuccess': isSuccess,
      'judgedAt': judgedAt?.toIso8601String(),
      // ========== V0.5 新增：标签序列化 ==========
      'tag': tag,
      // =========================================
    };
  }

  /// 从 Map（例如从JSON字符串解析而来）创建 Prediction 对象
  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'],
      content: json['content'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      isSuccess: json['isSuccess'],
      judgedAt: json['judgedAt'] != null ? DateTime.parse(json['judgedAt']) : null,
      // ========== V0.5 新增：标签反序列化 ==========
      // 注意：旧数据可能没有tag字段，所以这里需要处理null情况
      tag: json['tag'],
      // ===========================================
    );
  }
}