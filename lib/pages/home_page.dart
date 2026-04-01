// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../models/prediction.dart';  // 新增导入
import '../services/prediction_service.dart';
import '../widgets/prediction_card.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Prediction> _predictions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PredictionService.init();
      _loadPredictions();
    } catch (e) {
      print('应用初始化失败: $e');
      _loadPredictions();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadPredictions() {
    setState(() {
      _predictions = PredictionService.getAllPredictions();
    });
  }

  Future<void> _navigateToCreatePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePage()),
    );

    if (result == true) {
      _loadPredictions();
    }
  }

  Future<void> _navigateToDetailPage(String predictionId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(predictionId: predictionId),
      ),
    );

    if (result == true) {
      _loadPredictions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的预言'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('个人中心页面开发中...')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载预言中...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : _predictions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('还没有任何预言', style: TextStyle(fontSize: 18)),
                      Text('点击下方按钮创建第一个预言', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return PredictionCard(
                      prediction: prediction,
                      onTap: () => _navigateToDetailPage(prediction.id),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePage,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}