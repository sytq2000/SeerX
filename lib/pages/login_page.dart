// lib/pages/login_page.dart
// 描述：用户登录与注册页面
// 修改历史：
// V0.6 (2026-04-08)
//   - 新增：基于Supabase的邮箱登录/注册界面
//   - 功能：登录/注册模式切换、表单验证、错误提示
//   - 设计：Material Design 3 风格，响应式布局
//   - 修复：移除已弃用的useIsMounted，使用context.mounted替代
//   - 修复：移除局部变量下划线前缀，符合Dart代码规范
//   - 修复：注册/登录成功后跳转到首页，解决白屏问题
//   - 修复：添加HomePage导入，解决"The name 'HomePage' isn't a class"错误
//   - 修复：优化会话管理和错误处理

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});
  
  // 邮箱验证函数移到类级别
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  @override
  Widget build(BuildContext context) {
    final isLoginMode = useState(true);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    
    Future<void> submit() async {
      if (isLoading.value) return;
      
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      
      // 使用类方法验证邮箱
      if (!_isValidEmail(email)) {
        if (context.mounted) {
          errorMessage.value = '请输入有效的邮箱地址';
        }
        return;
      }
      
      if (email.isEmpty || password.isEmpty) {
        if (context.mounted) {
          errorMessage.value = '请输入邮箱和密码';
        }
        return;
      }
      
      if (!isLoginMode.value) {
        final confirmPassword = confirmPasswordController.text.trim();
        if (password != confirmPassword) {
          if (context.mounted) {
            errorMessage.value = '两次输入的密码不一致';
          }
          return;
        }
        if (password.length < 6) {
          if (context.mounted) {
            errorMessage.value = '密码至少需要6位';
          }
          return;
        }
      }
      
      if (context.mounted) {
        isLoading.value = true;
        errorMessage.value = null;
      }
      
      try {
        if (isLoginMode.value) {
          print('尝试登录: $email');
          await AuthService.signInWithEmail(
            email: email,
            password: password,
          );
          print('登录成功');
        } else {
          print('尝试注册: $email');
          await AuthService.signUpWithEmail(
            email: email,
            password: password,
          );
          print('注册成功');
        }
        
        // 注册/登录成功后，给一点时间让Supabase更新状态
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // 再次检查当前用户
        final currentUser = AuthService.currentUser;
        print('操作后当前用户: ${currentUser?.email ?? "未登录"}');
        
        if (currentUser == null) {
          // 如果用户仍然为空，可能是会话没有正确建立
          throw Exception('登录状态异常，请稍后重试');
        }
        
        // 成功，跳转到首页
        if (context.mounted) {
          print('注册/登录成功，跳转到首页');
          // 使用 pushAndRemoveUntil 确保清除所有路由
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        print('操作失败: $e');
        
        String errorMsg = e.toString();
        
        // 提供更友好的错误提示
        if (errorMsg.contains('Email not confirmed')) {
          errorMsg = '邮箱未确认。请检查您的邮箱并点击确认链接，或联系管理员确认账户。';
          
          // 如果是开发环境，添加额外提示
          if (email.contains('+test@')) {
            errorMsg += '\n\n提示：+test邮箱自动确认可能未启用，请在Supabase控制台手动确认邮箱。';
          }
        } else if (errorMsg.contains('email rate limit exceeded')) {
          errorMsg = '操作过于频繁，请等待15-30分钟再试。';
        } else if (errorMsg.contains('Invalid login credentials')) {
          errorMsg = '邮箱或密码错误';
        } else if (errorMsg.contains('User already registered')) {
          errorMsg = '该邮箱已注册，请直接登录';
        } else if (errorMsg.contains('login state abnormal')) {
          errorMsg = '登录状态异常，请尝试重新登录';
        } else {
          errorMsg = errorMsg.replaceAll('Exception: ', '');
        }
        
        if (context.mounted) {
          errorMessage.value = errorMsg;
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginMode.value ? '登录' : '注册'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 应用 Logo/标题
            const SizedBox(height: 40),
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'SeerX 预言系统',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '记录你的预言，验证你的直觉',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // 邮箱输入
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 16),
            
            // 密码输入
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            
            const SizedBox(height: 16),
            
            // 确认密码（注册模式显示）
            if (!isLoginMode.value)
              Column(
                children: [
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: '确认密码',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            // 错误提示
            if (errorMessage.value != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage.value!,
                  style: TextStyle(
                    color: Colors.red[700], // 修复：使用 Colors.red[700] 而不是 .shade700
                    fontSize: 14,
                  ),
                ),
              ),
            
            // 开发提示
            if (!isLoginMode.value)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '开发提示',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '如果使用"邮箱+test"格式仍然提示邮箱未确认，请在Supabase控制台手动确认邮箱。',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            
            // 提交按钮
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isLoginMode.value ? '登录' : '注册',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 切换模式
            TextButton(
              onPressed: isLoading.value
                  ? null
                  : () {
                      isLoginMode.value = !isLoginMode.value;
                      errorMessage.value = null;
                      passwordController.clear();
                      confirmPasswordController.clear();
                    },
              child: Text(
                isLoginMode.value
                    ? '没有账号？立即注册'
                    : '已有账号？立即登录',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 使用条款提示
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '注册即表示您同意我们的服务条款和隐私政策',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}