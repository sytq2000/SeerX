/// storage_service.dart
/// 版本: V0.6.2
/// 创建日期: 2026-04-10
/// 创建目的: 定义存储服务的抽象接口，为支持多种存储后端做准备
import '../../models/prediction.dart';

abstract class StorageService {
  // 获取所有预言
  Future<List<Prediction>> getAllPredictions();
  
  // 根据ID获取预言
  Future<Prediction?> getPredictionById(String id);
  
  // 创建预言
  Future<void> createPrediction(Prediction prediction);
  
  // 更新预言
  Future<void> updatePrediction(Prediction prediction);
  
  // 删除预言
  Future<void> deletePrediction(String id);
  
  // 根据状态筛选预言
  Future<List<Prediction>> getPredictionsByStatus(String status);
  
  // 搜索预言
  Future<List<Prediction>> searchPredictions(String keyword);
  
  // 获取统计数据
  Future<Map<String, dynamic>> getPredictionStats();
}