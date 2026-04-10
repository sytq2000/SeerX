/// remote_storage.dart
/// 版本: V0.6.2
/// 创建日期: 2026-04-10
/// 修改日期: 2026-04-10
/// 修改目的: 实现Supabase远程存储服务，支持用户数据隔离，修复Supabase 2.x API调用
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/prediction.dart';
import 'storage_service.dart';

class RemoteStorageService implements StorageService {
  final SupabaseClient _supabase;
  final String _userId;

  RemoteStorageService(this._supabase, this._userId);

  @override
  Future<List<Prediction>> getAllPredictions() async {
    try {
      final response = await _supabase
          .from('predictions')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Prediction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取预言失败: $e');
    }
  }

  @override
  Future<Prediction?> getPredictionById(String id) async {
    try {
      final response = await _supabase
          .from('predictions')
          .select()
          .eq('id', id)
          .eq('user_id', _userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final data = response as Map<String, dynamic>;
      return Prediction.fromJson(data);
    } catch (e) {
      throw Exception('获取预言失败: $e');
    }
  }

  @override
  Future<void> createPrediction(Prediction prediction) async {
    try {
      await _supabase
          .from('predictions')
          .insert(prediction.toJson());
    } catch (e) {
      throw Exception('创建预言失败: $e');
    }
  }

  @override
  Future<void> updatePrediction(Prediction prediction) async {
    try {
      await _supabase
          .from('predictions')
          .update(prediction.toJson())
          .eq('id', prediction.id)
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('更新预言失败: $e');
    }
  }

  @override
  Future<void> deletePrediction(String id) async {
    try {
      await _supabase
          .from('predictions')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('删除预言失败: $e');
    }
  }

  @override
  Future<List<Prediction>> getPredictionsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('predictions')
          .select()
          .eq('user_id', _userId)
          .eq('status', status)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Prediction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取预言失败: $e');
    }
  }

  @override
  Future<List<Prediction>> searchPredictions(String keyword) async {
    try {
      final response = await _supabase
          .from('predictions')
          .select()
          .eq('user_id', _userId)
          .ilike('title', '%$keyword%')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Prediction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('搜索预言失败: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPredictionStats() async {
    try {
      final predictions = await getAllPredictions();
      
      final total = predictions.length;
      final successful = predictions.where((p) => p.status == 'successful').length;
      final failed = predictions.where((p) => p.status == 'failed').length;
      final pending = predictions.where((p) => p.status == 'pending').length;
      final judging = predictions.where((p) => p.status == 'judging').length;
      final successRate = total > 0 ? (successful / total * 100) : 0.0;
      
      return {
        'total': total,
        'successful': successful,
        'failed': failed,
        'pending': pending,
        'judging': judging,
        'successRate': successRate,
      };
    } catch (e) {
      throw Exception('获取统计数据失败: $e');
    }
  }
}