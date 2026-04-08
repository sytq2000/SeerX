// lib/main.dart
// 描述：应用入口文件，初始化全局服务和配置
// 修改历史：
// V0.6 (2026-04-08) - 小明
//   - 新增：Supabase初始化与环境变量加载
//   - 修改：应用入口从LoginPage改为HomePage，实现自动登录路由
//   - 依赖：新增 flutter_dotenv, supabase_flutter
//   - 移除：shared_preferences（当前未使用）
//
// V0.1 (2026-03-26) - 小明
//   - 初始版本：基础应用框架

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';

void main() async {
  // ========== V0.6 新增：异步初始化流程 ==========
  WidgetsFlutterBinding.ensureInitialized();
  
  // 加载环境变量（Supabase密钥等）
  await dotenv.load(fileName: ".env");
  
  // 初始化Supabase客户端
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  // ===============================================
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeerX 预言系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,  // 启用Material 3
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // ========== V0.6 修改：首页入口变更 ==========
      // 从直接登录页改为首页，由首页负责登录状态路由
      home: const HomePage(),
      // ===========================================
      debugShowCheckedModeBanner: false,
    );
  }
}