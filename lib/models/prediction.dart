// lib/models/prediction.dart
class Prediction {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime dueDate;
  final String status; // 'pending', 'judging', 'success', 'failure'
  final bool? isSuccess;
  final DateTime? judgedAt;
  
  Prediction({
    required this.id,
    required this.content,
    required this.dueDate,
    this.status = 'pending',
    this.isSuccess,
    this.judgedAt,
  }) : createdAt = DateTime.now();
  
  // 创建一个更新状态的副本
  Prediction copyWith({
    String? status,
    bool? isSuccess,
    DateTime? judgedAt,
  }) {
    return Prediction(
      id: id,
      content: content,
      dueDate: dueDate,
      status: status ?? this.status,
      isSuccess: isSuccess ?? this.isSuccess,
      judgedAt: judgedAt ?? this.judgedAt,
    );
  }

  // === 新增代码开始：V0.2 数据持久化支持 ===
  
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
    );
  }
  // === 新增代码结束 ===
}