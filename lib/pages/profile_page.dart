// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../services/prediction_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 状态变量
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// 加载统计数据
  void _loadStats() {
    setState(() {
      _stats = PredictionService.getPredictionStats();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 加载状态显示
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('个人中心'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('加载统计数据中...'),
            ],
          ),
        ),
      );
    }

    // 从 _stats 中获取真实数据
    final int totalPredictions = _stats['total'] ?? 0;
    final int successfulPredictions = _stats['successful'] ?? 0;
    final int failedPredictions = _stats['failed'] ?? 0;
    final int pendingPredictions = _stats['pending'] ?? 0;
    final int judgingPredictions = _stats['judging'] ?? 0;
    final double successRate = _stats['successRate'] ?? 0.0;

    // 用户信息（暂时保持模拟，未来可从 AuthService 获取）
    final String userName = '预言家小明';
    final String userEmail = 'seer@example.com';
    final String joinDate = '2026年3月20日';

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              // 短暂延迟后重新加载，让用户看到加载效果
              Future.delayed(const Duration(milliseconds: 300), () {
                _loadStats();
              });
            },
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== 用户信息卡片 ==========
            _buildUserInfoCard(context, userName, userEmail, joinDate),

            const SizedBox(height: 24),

            // ========== 数据总览标题 ==========
            Text(
              '📊 预言数据总览（共 $totalPredictions 条）',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '基于你所有的预言记录',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // ========== 核心数据卡片 ==========
            Row(
              children: [
                // 总预言数卡片
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: '总预言数',
                    value: totalPredictions.toString(),
                    icon: Icons.list_alt,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                // 成功率卡片
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: '预言成功率',
                    value: '${successRate.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ========== 状态分布卡片 ==========
            _buildStatusDistributionCard(
              context,
              successful: successfulPredictions,
              failed: failedPredictions,
              pending: pendingPredictions,
              judging: judgingPredictions,
              total: totalPredictions,
            ),

            const SizedBox(height: 24),

            // ========== 功能入口区域 ==========
            const Text(
              '⚙️ 功能与设置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildFunctionItem(
              context,
              icon: Icons.settings,
              title: '账户设置',
              subtitle: '修改个人信息与偏好',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('账户设置功能开发中...')),
                );
              },
            ),
            _buildFunctionItem(
              context,
              icon: Icons.notifications,
              title: '通知设置',
              subtitle: '管理预言到期提醒',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('通知设置功能开发中...')),
                );
              },
            ),
            _buildFunctionItem(
              context,
              icon: Icons.help_outline,
              title: '帮助与反馈',
              subtitle: '查看使用指南或报告问题',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('帮助与反馈功能开发中...')),
                );
              },
            ),

            const SizedBox(height: 20),

            // ========== 退出登录按钮 ==========
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: 实现退出登录逻辑
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('退出登录功能开发中...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  '退出登录',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 自定义组件方法 ==========

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(
    BuildContext context,
    String userName,
    String userEmail,
    String joinDate,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 用户头像
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 20),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '加入时间: $joinDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // 编辑按钮
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('编辑资料功能开发中...')),
                );
              },
              icon: const Icon(Icons.edit, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计数据卡片
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态分布卡片
  Widget _buildStatusDistributionCard(
    BuildContext context, {
    required int successful,
    required int failed,
    required int pending,
    required int judging,
    required int total,
  }) {
    // 计算各状态比例（用于视觉指示条）
    final double successRatio = total > 0 ? successful / total : 0;
    final double failedRatio = total > 0 ? failed / total : 0;
    final double pendingRatio = total > 0 ? pending / total : 0;
    final double judgingRatio = total > 0 ? judging / total : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '预言状态分布',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '共 $total 条预言',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // 状态分布指示条
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  // 成功部分
                  if (successRatio > 0)
                    Expanded(
                      flex: (successRatio * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  // 失败部分
                  if (failedRatio > 0)
                    Expanded(
                      flex: (failedRatio * 100).round(),
                      child: Container(color: Colors.red),
                    ),
                  // 待裁决部分
                  if (judgingRatio > 0)
                    Expanded(
                      flex: (judgingRatio * 100).round(),
                      child: Container(color: Colors.orange),
                    ),
                  // 待验证部分
                  if (pendingRatio > 0)
                    Expanded(
                      flex: (pendingRatio * 100).round(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 状态图例
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildStatusLegend(
                  color: Colors.green,
                  label: '预言成功',
                  count: successful,
                ),
                _buildStatusLegend(
                  color: Colors.red,
                  label: '预言失败',
                  count: failed,
                ),
                _buildStatusLegend(
                  color: Colors.orange,
                  label: '待裁决',
                  count: judging,
                ),
                _buildStatusLegend(
                  color: Colors.grey,
                  label: '待验证',
                  count: pending,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态图例项
  Widget _buildStatusLegend({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// 构建功能列表项
  Widget _buildFunctionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}