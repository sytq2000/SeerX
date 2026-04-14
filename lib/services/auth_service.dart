// lib/services/auth_service.dart
// 描述：用户认证服务，处理登录、注册、退出等身份验证逻辑
// 修改历史：
// V0.6 (2026-04-08)
//   - 新增：基于Supabase的完整邮箱认证服务
//   - 功能：用户注册、登录、退出、状态监听
//   - 依赖：supabase_flutter

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  /// 获取当前用户
  static User? get currentUser {
    return _supabase.auth.currentUser;
  }
  
  /// 检查用户是否已登录
  static bool get isLoggedIn {
    return _supabase.auth.currentUser != null;
  }


    /// 获取当前会话
  static Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  /// 强制刷新会话
  static Future<Session?> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response.session;
    } catch (e) {
      print('刷新会话失败: $e');
      return null;
    }
  }
  
  /// 邮箱注册
  static Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('注册失败，请重试');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 邮箱登录
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('登录失败，请检查邮箱和密码');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 退出登录
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  /// 监听认证状态变化
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  static Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('退出登录失败: $e');
      rethrow;
    }
  }


}