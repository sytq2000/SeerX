// lib/services/prediction_service.dart
import 'dart:convert';  // 新增导入
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction.dart';

class PredictionService {
  static const String _storageKey = 'seerx_predictions';
  static List<Prediction> _predictions = [];

  static Future<void> init() async {
    await _loadFromStorage();
  }

  static List<Prediction> getAllPredictions() {
    return List.from(_predictions);
  }

  static Future<void> addPrediction(String content, DateTime dueDate) async {
  final now = DateTime.now();
  
  // 计算正确的初始状态
  String initialStatus = 'pending'; // 默认待验证
  
  // 如果到期时间已经过去，应该直接进入"待裁决"状态
  if (dueDate.isBefore(now) || dueDate.isAtSameMomentAs(now)) {
    initialStatus = 'judging';
  }
  
  final newPrediction = Prediction(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: content,
    dueDate: dueDate,
    status: initialStatus, // 使用计算出的状态
  );
  
  _predictions.insert(0, newPrediction);
  await _saveToStorage();
}

  static Future<void> judgePrediction(String id, bool isSuccess) async {
    final index = _predictions.indexWhere((p) => p.id == id);
    if (index != -1) {
      _predictions[index] = _predictions[index].copyWith(
        status: isSuccess ? 'success' : 'failure',
        isSuccess: isSuccess,
        judgedAt: DateTime.now(),
      );
      await _saveToStorage();
    }
  }

  static Prediction? getPredictionById(String id) {
    try {
      return _predictions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _predictions = jsonList
            .map((json) => Prediction.fromJson(json))
            .toList();
        print('✅ 从本地存储加载了 ${_predictions.length} 条预言');
      } else {
        _initWithSampleData();
        await _saveToStorage();
        print('🆕 初始化为示例数据');
      }
    } catch (e) {
      print('❌ 加载存储数据失败: $e，将使用示例数据');
      _initWithSampleData();
    }
  }

  static Future<void> _saveToStorage() async {
    try {
      final jsonList = _predictions.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonString);
      print('💾 已保存 ${_predictions.length} 条预言到本地存储');
    } catch (e) {
      print('❌ 保存数据到本地存储失败: $e');
    }
  }

  static void _initWithSampleData() {
    _predictions = [
      Prediction(
        id: '1',
        content: '我预测明天会下雨',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Prediction(
        id: '2',
        content: '我预测上证指数4月1日会到3400点',
        dueDate: DateTime(2026, 4, 1),
        status: 'judging',
      ),
      Prediction(
        id: '3',
        content: '我预测这周末会出太阳',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'success',
        isSuccess: true,
        judgedAt: DateTime.now(),
      ),
    ];
  }
  // ========== 新增：V0.3 数据统计方法 ==========

  /// 获取用户预言统计数据
  static Map<String, dynamic> getPredictionStats() {
    final now = DateTime.now();
    int total = _predictions.length;
    int successful = 0;
    int failed = 0;
    int pending = 0;
    int judging = 0;
    
    // 遍历所有预言，按状态分类计数
    for (var prediction in _predictions) {
      switch (prediction.status) {
        case 'success':
          successful++;
          break;
        case 'failure':
          failed++;
          break;
        case 'judging':
          judging++;
          break;
        case 'pending':
          // 检查是否需要自动更新为"待裁决"
          if (prediction.dueDate.isBefore(now) || 
              prediction.dueDate.isAtSameMomentAs(now)) {
            judging++; // 统计时计入待裁决
          } else {
            pending++;
          }
          break;
      }
    }
    
    // 计算成功率（避免除零错误）
    double successRate = 0.0;
    int judgedTotal = successful + failed;
    if (judgedTotal > 0) {
      successRate = (successful / judgedTotal) * 100;
    }
    
    return {
      'total': total,
      'successful': successful,
      'failed': failed,
      'pending': pending,
      'judging': judging,
      'successRate': successRate,
    };
  }

  /// 获取最近的预言（用于可能的趋势分析）
  static List<Prediction> getRecentPredictions({int limit = 10}) {
    if (_predictions.isEmpty) return [];
    
    // 按创建时间倒序排列，取最新的
    List<Prediction> sorted = List.from(_predictions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sorted.take(limit).toList();
  }


}