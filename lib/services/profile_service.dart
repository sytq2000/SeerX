// 修正后的 profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';  // 使用重命名后的文件

class ProfileService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取当前用户的完整信息
  static Future<AppUser> getCurrentUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('用户未登录');
      }

      // 从 profiles 表获取用户资料
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      if (response == null) {
        // 如果 profiles 表中没有记录，创建默认用户信息
        return AppUser(
          id: currentUser.id,
          email: currentUser.email ?? '未设置邮箱',
          nickname: null,
          avatarUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final profileData = response as Map<String, dynamic>;
      
      return AppUser(
        id: currentUser.id,
        email: currentUser.email ?? '未设置邮箱',
        nickname: profileData['nickname']?.toString(),
        avatarUrl: profileData['avatar_url']?.toString(),
        createdAt: profileData['created_at'] != null
            ? DateTime.tryParse(profileData['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: profileData['updated_at'] != null
            ? DateTime.tryParse(profileData['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print('获取用户信息错误: $e');
      
      // 如果获取失败，尝试从 auth 获取基本信息
      try {
        final authUser = _supabase.auth.currentUser;
        if (authUser != null) {
          return AppUser(
            id: authUser.id,
            email: authUser.email ?? '未设置邮箱',
            nickname: null,
            avatarUrl: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } catch (e2) {
        print('从 auth 获取用户失败: $e2');
      }
      
      rethrow;
    }
  }

  /// 检查昵称是否可用
  static Future<bool> isNicknameAvailable(String nickname) async {
    try {
      if (nickname.isEmpty) {
        return false;
      }

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('用户未登录');
      }

      // 先检查是否是自己当前的昵称
      try {
        final myProfile = await _supabase
            .from('profiles')
            .select('nickname')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (myProfile != null) {
          final myProfileData = myProfile as Map<String, dynamic>;
          final myNickname = myProfileData['nickname'] as String?;
          if (myNickname == nickname) {
            return true; // 可以继续使用当前的昵称
          }
        }
      } catch (e) {
        // 如果查询出错，可能是用户还没有 profile 记录
        print('查询个人昵称失败: $e');
      }

      // 检查其他用户是否使用了这个昵称
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('nickname', nickname);

      if (response == null) {
        return true; // 没有找到使用此昵称的用户
      }

      final List<dynamic> users = response as List<dynamic>;
      return users.isEmpty; // 空表示昵称可用
    } catch (e) {
      print('检查昵称可用性错误: $e');
      rethrow;
    }
  }

  /// 更新用户资料
  static Future<void> updateProfile({
    required String nickname,
    String? avatarUrl,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('用户未登录');
      }

      final updateData = <String, dynamic>{
        'nickname': nickname,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // 只更新非空的头像 URL
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        updateData['avatar_url'] = avatarUrl;
      }

      // 尝试更新现有记录
      await _supabase
          .from('profiles')
          .upsert({
            'id': currentUser.id,
            ...updateData,
            'created_at': updateData['updated_at'], // 如果不存在则创建
          });
    } catch (e) {
      print('更新用户资料错误: $e');
      rethrow;
    }
  }
}