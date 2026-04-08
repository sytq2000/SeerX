// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({super.key, required this.status});
  
  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'judging':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'failure':
        return Colors.red;
      case 'judged':  // 添加对'judged'的处理
        return Colors.blue; // 或者根据实际情况返回颜色
      default:
        return Colors.grey; // 默认颜色
    }
  }
  
  String _getStatusText() {
    switch (status) {
      case 'pending':
        return '待验证';
      case 'judging':
        return '待裁决';
      case 'success':
        return '预言成功';
      case 'failure':
        return '预言失败';
      case 'judged':  // 添加对'judged'的处理
        return '已裁决'; // 或者根据实际情况返回文本
      default:
        return '未知'; // 你截图中显示的是这个
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}