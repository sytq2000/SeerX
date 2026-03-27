// lib/pages/home_page.dart
import 'package:flutter/material.dart';
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
  List _predictions = [];
  
  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }
  
  void _loadPredictions() {
    setState(() {
      _predictions = PredictionService.getAllPredictions();
    });
  }
  
  void _navigateToCreatePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePage()),
    );
    
    // 如果创建了新的预言，重新加载列表
    if (result == true) {
      _loadPredictions();
    }
  }
  
  void _navigateToDetailPage(String predictionId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(predictionId: predictionId),
      ),
    );
    
    // 如果裁决了预言，重新加载列表
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
              // 个人中心页（后续实现）
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('个人中心页面开发中...')),
              );
            },
          ),
        ],
      ),
      
      body: _predictions.isEmpty
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