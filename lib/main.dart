// lib/main.dart
// 描述：应用入口文件，初始化全局服务和配置
// 修改历史：
// V0.6.1 (2026-04-10)
// - 修复：Undefined name 'kDebugMode'
// - 修复：No named parameter with the name 'redirectUrl'
// - 修复：添加正确的 Supabase URL
// - 修复：优化 Supabase 初始化参数

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;  // 修复1：添加 kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';

void main() async {
  print('🚀 应用开始启动...');
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ Flutter 引擎初始化完成');
    
    String supabaseUrl;
    String supabaseAnonKey;
    
    if (kIsWeb) {
      // ========== Web平台：使用硬编码配置 ==========
      print('🌐 Web环境：使用硬编码配置');
      // ✅ 修复：使用正确的 Supabase URL
      supabaseUrl = 'https://ufsoqmhvouijhhplaydd.supabase.co';  // 🔥 填入正确的 URL
      // ✅ 您的 anonKey
      supabaseAnonKey = 'sb_publishable_MYIWKqH4NAbAj5BMYsdsXQ_MehH3omo';
      
      print('🔌 Web Supabase URL: $supabaseUrl');
      print('🔑 Web Supabase Key: ${supabaseAnonKey.substring(0, 20)}...');
    } else {
      // ========== 移动端/桌面端：从.env文件加载 ==========
      print('📱 移动端环境：从.env文件加载配置');
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL']!;
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
      
      print('🔌 Mobile Supabase URL: $supabaseUrl');
      print('🔑 Mobile Supabase Key: ${supabaseAnonKey.substring(0, 20)}...');
    }
    
    // 初始化 Supabase
    print('🔌 开始初始化 Supabase...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // ✅ 移除不存在的参数
      debug: kDebugMode,  // 使用正确的 kDebugMode
      // ❌ 移除不存在的 redirectUrl 参数
      // ❌ 移除不存在的 authFlowType 参数
    );
    
    print('✅ Supabase 初始化完成');
    
    // 运行应用
    print('🎯 启动 Flutter 应用...');
    runApp(const MyApp());
    
  } catch (e, stackTrace) {
    print('❌ 应用启动失败: $e');
    print('📋 堆栈跟踪: $stackTrace');
    
    // 显示错误页面
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  '应用启动失败',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  '错误: $e',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  '可能的原因：\n1. Supabase 配置错误\n2. 网络连接问题\n3. 环境变量加载失败',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 在实际应用中，这里可以添加更复杂的恢复逻辑
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeerX 预言系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 首页入口变更
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}