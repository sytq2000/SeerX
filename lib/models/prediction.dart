// lib/models/prediction.dart 数据模型
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
}