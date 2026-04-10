/// prediction_service.dart
/// 版本: V0.6.2
/// 修改日期: 2026-04-10
/// 修改目的: 修复裁决逻辑，添加judgedAt字段更新
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/prediction.dart';
import 'auth_service.dart';
import 'storage/storage_manager.dart';

class PredictionService {
  // 获取所有预言
  static Future<List<Prediction>> getAllPredictions() async {
    try {
      final storage = await StorageManager.getStorage();
      return await storage.getAllPredictions();
    } catch (e) {
      debugPrint('获取预言列表失败: $e');
      return [];
    }
  }

  // 根据ID获取预言
  static Future<Prediction?> getPredictionById(String id) async {
    try {
      final storage = await StorageManager.getStorage();
      return await storage.getPredictionById(id);
    } catch (e) {
      debugPrint('获取预言失败: $e');
      return null;
    }
  }

  // 创建预言
  static Future<void> createPrediction(Prediction prediction) async {
    try {
      final storage = await StorageManager.getStorage();
      await storage.createPrediction(prediction);
    } catch (e) {
      debugPrint('创建预言失败: $e');
      rethrow;
    }
  }

  // 更新预言
  static Future<void> updatePrediction(Prediction prediction) async {
    try {
      final storage = await StorageManager.getStorage();
      await storage.updatePrediction(prediction);
    } catch (e) {
      debugPrint('更新预言失败: $e');
      rethrow;
    }
  }

  // 删除预言
  static Future<void> deletePrediction(String id) async {
    try {
      final storage = await StorageManager.getStorage();
      await storage.deletePrediction(id);
    } catch (e) {
      debugPrint('删除预言失败: $e');
      rethrow;
    }
  }

  // 根据状态筛选预言
  static Future<List<Prediction>> getPredictionsByStatus(String status) async {
    try {
      final storage = await StorageManager.getStorage();
      return await storage.getPredictionsByStatus(status);
    } catch (e) {
      debugPrint('获取状态预言失败: $e');
      return [];
    }
  }

  // 搜索预言
  static Future<List<Prediction>> searchPredictions(String keyword) async {
    try {
      final storage = await StorageManager.getStorage();
      return await storage.searchPredictions(keyword);
    } catch (e) {
      debugPrint('搜索预言失败: $e');
      return [];
    }
  }

  // 获取统计数据
  static Future<Map<String, dynamic>> getPredictionStats() async {
    try {
      final storage = await StorageManager.getStorage();
      return await storage.getPredictionStats();
    } catch (e) {
      debugPrint('获取统计数据失败: $e');
      return {
        'total': 0,
        'successful': 0,
        'failed': 0,
        'pending': 0,
        'judging': 0,
        'successRate': 0.0,
      };
    }
  }

  // 兼容方法：添加预言（旧接口）
  static Future<void> addPrediction({
    required String title,
    required String content,
    required DateTime dueDate,
    String tag = 'general',
    bool isSuccess = false,
  }) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('用户未登录，无法添加预言');
      }

      // 创建预言对象
      final prediction = Prediction(
        id: const Uuid().v4(),
        userId: currentUser.id,
        title: title,
        description: content,
        predictionDate: DateTime.now(),
        verificationDate: dueDate,
        status: 'pending',
        tags: [tag],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createPrediction(prediction);
    } catch (e) {
      debugPrint('通过兼容接口添加预言失败: $e');
      rethrow;
    }
  }

  // 判断预言结果
  static Future<void> judgePrediction(String id, bool isSuccess) async {
    try {
      // 先获取现有的预言
      final prediction = await getPredictionById(id);
      if (prediction == null) {
        throw Exception('找不到ID为$id的预言');
      }

      // 使用Prediction的judge方法
      final judgedPrediction = prediction.copyWith(
        status: isSuccess ? 'successful' : 'failed',
        updatedAt: DateTime.now(),
        judgedAt: DateTime.now(), // 新增：记录裁决时间
      );

      await updatePrediction(judgedPrediction);
    } catch (e) {
      debugPrint('判断预言结果失败: $e');
      rethrow;
    }
  }

  // 兼容方法：更新预言结果
  static Future<void> updatePredictionResult({
    required String id,
    required bool isSuccess,
    DateTime? judgedAt,
  }) async {
    try {
      // 先获取现有的预言
      final prediction = await getPredictionById(id);
      if (prediction == null) {
        throw Exception('找不到ID为$id的预言');
      }

      // 更新预言状态
      final updatedPrediction = prediction.copyWith(
        status: isSuccess ? 'successful' : 'failed',
        updatedAt: DateTime.now(),
        judgedAt: judgedAt ?? DateTime.now(), // 使用传入的judgedAt，如果为null则用当前时间
      );

      await updatePrediction(updatedPrediction);
    } catch (e) {
      debugPrint('更新预言结果失败: $e');
      rethrow;
    }
  }

  // 获取过期预言
  static Future<List<Prediction>> getExpiredPredictions() async {
    try {
      final allPredictions = await getAllPredictions();
      final now = DateTime.now();
      
      return allPredictions.where((prediction) {
        return prediction.status == 'pending' && 
               prediction.verificationDate.isBefore(now);
      }).toList();
    } catch (e) {
      debugPrint('获取过期预言失败: $e');
      return [];
    }
  }

  // 获取近期预言
  static Future<List<Prediction>> getUpcomingPredictions() async {
    try {
      final allPredictions = await getAllPredictions();
      final now = DateTime.now();
      final oneWeekLater = now.add(const Duration(days: 7));
      
      return allPredictions.where((prediction) {
        return prediction.status == 'pending' && 
               prediction.verificationDate.isAfter(now) &&
               prediction.verificationDate.isBefore(oneWeekLater);
      }).toList();
    } catch (e) {
      debugPrint('获取近期预言失败: $e');
      return [];
    }
  }
}