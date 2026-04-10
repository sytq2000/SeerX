// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({super.key, required this.status});
  


  Color _getStatusColor() {
  switch (status) {
    case 'pending':
      return Colors.grey; // 灰色
    case 'judging':
      return Colors.orange;
    case 'successful':
      return Colors.green; // 绿色
    case 'failed':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
  
  
  String _getStatusText() {
    switch (status) {
      case 'pending':
        return '待验证';
      case 'judging':
        return '待裁决';
      case 'successful':  // 修复：改为'successful'
        return '预言成功';
      case 'failed':      // 修复：改为'failed'
        return '预言失败';
      default:
        return '未知';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
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