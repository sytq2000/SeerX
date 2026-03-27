// lib/services/prediction_service.dart 本地数据服务 
import '../models/prediction.dart';

class PredictionService {
  // 模拟内存数据库
  static List<Prediction> _predictions = [
    Prediction(
      id: '1',
      content: '我预测明天会下雨',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Prediction(
      id: '2',
      content: '我预测上证指数4月1日会到3400点',
      dueDate: DateTime(2026, 4, 1),
      status: 'judging', // 待裁决状态
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
  
  // 获取所有预测
  static List<Prediction> getAllPredictions() {
    return List.from(_predictions);
  }
  
  // 添加新预测
  static void addPrediction(String content, DateTime dueDate) {
    final newPrediction = Prediction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      dueDate: dueDate,
    );
    _predictions.insert(0, newPrediction);
  }
  
  // 裁决预测
  static void judgePrediction(String id, bool isSuccess) {
    final index = _predictions.indexWhere((p) => p.id == id);
    if (index != -1) {
      _predictions[index] = _predictions[index].copyWith(
        status: isSuccess ? 'success' : 'failure',  // 改成 success 或 failure
        isSuccess: isSuccess,
        judgedAt: DateTime.now(),
      );
    }
  }
  
  // 获取单个预测
  static Prediction? getPredictionById(String id) {
    try {
      return _predictions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}