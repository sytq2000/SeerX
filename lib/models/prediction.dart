/*
  prediction.dart
  版本: V0.6.2
  修改日期: 2026-04-10
  修改目的: 修复状态计算和显示问题
*/

class Prediction {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime predictionDate;
  final DateTime verificationDate;
  final String _status; // 数据库原始状态
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? judgedAt; // 裁决时间

  Prediction({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.predictionDate,
    required this.verificationDate,
    required String status,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.judgedAt,
  }) : _status = status;

  // 从JSON转换
  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      predictionDate: DateTime.parse(json['prediction_date'] as String).toLocal(),
      verificationDate: DateTime.parse(json['verification_date'] as String).toLocal(),
      status: json['status'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      judgedAt: json['judged_at'] != null
          ? DateTime.parse(json['judged_at'] as String).toLocal()
          : null,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'prediction_date': predictionDate.toUtc().toIso8601String(),
      'verification_date': verificationDate.toUtc().toIso8601String(),
      'status': _status,
      'tags': tags,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'judged_at': judgedAt?.toUtc().toIso8601String(),
    };
  }

  // 获取数据库中的原始状态
  String get rawStatus => _status;

  // 获取计算后的状态（核心修复）
  String get status {
    // 如果已经裁决，直接返回数据库状态
    if (_status == 'successful' || _status == 'failed') {
      return _status;
    }

    // 如果数据库状态是 'judging'，直接返回
    if (_status == 'judging') {
      return 'judging';
    }

    // 否则，根据时间计算状态
    final now = DateTime.now();
    final verificationDateTime = verificationDate;

    // 比较逻辑：只比较年月日，忽略时分秒
    final verificationDateOnly = DateTime(
      verificationDateTime.year,
      verificationDateTime.month,
      verificationDateTime.day,
    );

    final nowDateOnly = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // 如果当前日期 >= 验证日期，则为 'judging'，否则为 'pending'
    if (nowDateOnly.isAfter(verificationDateOnly) ||
        nowDateOnly.isAtSameMomentAs(verificationDateOnly)) {
      return 'judging';
    } else {
      return 'pending';
    }
  }

  // 获取状态显示文本
  String get statusText {
    switch (status) {
      case 'pending':
        return '待验证';
      case 'judging':
        return '待裁决';
      case 'successful':
        return '预言成功';
      case 'failed':
        return '预言失败';
      default:
        return '未知';
    }
  }


  // 找到 statusColor getter 方法，修改为：
  int get statusColor {
    switch (status) {
      case 'pending':
        return 0xFF9E9E9E; // 灰色
      case 'judging':
        return 0xFFFF9800; // 橙色
      case 'successful':
        return 0xFF4CAF50; // 绿色
      case 'failed':
        return 0xFFF44336; // 红色
      default:
        return 0xFF9E9E9E; // 默认灰色
    }
  }



  

  // 是否已裁决
  bool? get isSuccess {
    if (status == 'successful') return true;
    if (status == 'failed') return false;
    return null;
  }

  // 复制方法
  Prediction copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? predictionDate,
    DateTime? verificationDate,
    String? status,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? judgedAt,
  }) {
    return Prediction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      predictionDate: predictionDate ?? this.predictionDate,
      verificationDate: verificationDate ?? this.verificationDate,
      status: status ?? this._status,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      judgedAt: judgedAt ?? this.judgedAt,
    );
  }

  // 裁决方法
  Prediction judge(bool isSuccess) {
    return copyWith(
      status: isSuccess ? 'successful' : 'failed',
      updatedAt: DateTime.now(),
      judgedAt: DateTime.now(),
    );
  }

  // 兼容性getter
  String get content => description;
  DateTime get dueDate => verificationDate;
  String get tag => tags.isNotEmpty ? tags.first : 'general';
}