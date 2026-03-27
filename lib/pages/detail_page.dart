// lib/pages/detail_page.dart
import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/prediction_service.dart';
import '../widgets/status_badge.dart';

class DetailPage extends StatefulWidget {
  final String predictionId;
  
  const DetailPage({super.key, required this.predictionId});
  
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Prediction? _prediction;
  
  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }
  
  void _loadPrediction() {
    setState(() {
      _prediction = PredictionService.getPredictionById(widget.predictionId);
    });
  }
  
void _judgePrediction(bool isSuccess) {
  if (_prediction != null) {
    // 更新数据
    PredictionService.judgePrediction(_prediction!.id, isSuccess);
    
    // 立即刷新当前页面的显示
    setState(() {
      _prediction = PredictionService.getPredictionById(widget.predictionId);
    });
    
    // 等待0.8秒，让用户看到状态已更新
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }
}
  
  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    if (_prediction == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('预言详情'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('预言不存在'),
        ),
      );
    }
    
    final prediction = _prediction!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('预言详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态徽章
            StatusBadge(status: prediction.status),
            
            const SizedBox(height: 24),
            
            // 预言内容
            const Text(
              '预言内容',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prediction.content,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 详细信息
            const Text(
              '详细信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildDetailItem('创建时间', _formatDateTime(prediction.createdAt)),
            _buildDetailItem('到期时间', _formatDateTime(prediction.dueDate)),
            
            if (prediction.judgedAt != null)
              _buildDetailItem('裁决时间', _formatDateTime(prediction.judgedAt!)),
            
            if (prediction.isSuccess != null)
              _buildDetailItem(
                '裁决结果',
                prediction.isSuccess! ? '预言成功 ✅' : '预言失败 ❌',
              ),
            
            const SizedBox(height: 40),
            
            // 裁决区域（仅当待裁决状态时显示）
            if (prediction.status == 'judging') _buildJudgementSection(),
            
            // 结果展示区域（已裁决时显示）
            if (prediction.status == 'success' || prediction.status == 'failure')
              _buildResultSection(prediction),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildJudgementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                '等待裁决',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '时间已到，请根据事实判断这个预言是否实现：',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _judgePrediction(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text('预言成功'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _judgePrediction(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, size: 20),
                      SizedBox(width: 8),
                      Text('预言失败'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '提示：请根据客观事实进行判断，裁决后结果不可更改',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
  



  Widget _buildResultSection(Prediction prediction) {
    final isSuccess = prediction.isSuccess == true;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.celebration : Icons.sentiment_dissatisfied,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isSuccess ? '🎉 预言成功！' : '❌ 预言失败',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            isSuccess
                ? '你的预言准确实现！继续保持准确的直觉。'
                : '预言未能实现，下次会更好的！',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          
          if (prediction.judgedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '裁决时间: ${_formatDateTime(prediction.judgedAt!)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}