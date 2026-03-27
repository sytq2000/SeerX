// lib/services/auth_service.dart
class AuthService {
  // 模拟登录状态
  static bool _isLoggedIn = false;
  static String _currentUser = '';
  
  static bool get isLoggedIn => _isLoggedIn;
  static String get currentUser => _currentUser;
  
  // 模拟登录
  static void login(String username) {
    _isLoggedIn = true;
    _currentUser = username;
  }
  
  // 模拟登出
  static void logout() {
    _isLoggedIn = false;
    _currentUser = '';
  }
}