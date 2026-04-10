/// storage_manager.dart
/// 版本: V0.6.2
/// 创建日期: 2026-04-10
/// 创建目的: 管理存储服务实例，根据用户状态返回合适的存储实现
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import 'remote_storage.dart';
import 'storage_service.dart';

class StorageManager {
  static Future<StorageService> getStorage() async {
    final currentUser = AuthService.currentUser;
    
    if (currentUser == null) {
      // 用户未登录，应该不会发生这种情况
      // 在V0.6.3中，这里会返回LocalStorage
      throw Exception('用户未登录，无法获取存储服务');
    }
    
    // 当前用户已登录，使用RemoteStorage
    return RemoteStorageService(
      Supabase.instance.client,
      currentUser.id,
    );
  }
}