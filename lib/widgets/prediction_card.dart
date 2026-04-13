// lib/widgets/prediction_card.dart
import 'package:flutter/material.dart';
import '../models/prediction.dart';
// 注释掉旧的StatusBadge导入
// import 'status_badge.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback? onTap;
  
  const PredictionCard({
    super.key,
    required this.prediction,
    this.onTap,
  });
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态和日期行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 使用Prediction的statusText和statusColor
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(prediction.statusColor).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(prediction.statusColor),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      prediction.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(prediction.statusColor),
                      ),
                    ),
                  ),
                  Text(
                    '到期: ${_formatDate(prediction.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 预言内容
              Text(
                prediction.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // 创建时间
              Text(
                '创建: ${_formatDate(prediction.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}