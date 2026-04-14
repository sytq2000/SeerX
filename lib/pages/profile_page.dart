// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../services/prediction_service.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import 'edit_profile_page.dart';
import '../models/app_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 状态变量
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  AppUser? _currentUser;                      // 使用 AppUser
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();      // 加载用户信息
    _loadStats();         // 加载统计数据
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    try {
      if (AuthService.isLoggedIn) {
        debugPrint('开始加载用户数据...');
        
        // 从 ProfileService 获取用户资料
        final user = await ProfileService.getCurrentUser();
        debugPrint('用户数据加载成功: ${user.email}, 昵称: ${user.nickname}');
        
        if (mounted) {
          setState(() {
            _currentUser = user;  // 正确赋值给实例变量
            _isLoadingUser = false;
          });
        }
      } else {
        debugPrint('用户未登录');
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      debugPrint('加载用户数据失败: $e');
      
      // 即使出错，也尝试从 auth 获取基本信息
      try {
        final authUser = AuthService.currentUser;
        if (authUser != null && mounted) {
          setState(() {
            _currentUser = AppUser(
              id: authUser.id,
              email: authUser.email ?? '未设置邮箱',
              nickname: authUser.email?.split('@').first,  // 使用邮箱前缀作为默认昵称
              avatarUrl: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            _isLoadingUser = false;
          });
        }
      } catch (e2) {
        debugPrint('从 auth 获取用户失败: $e2');
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
          });
        }
      }
      
      // 显示错误提示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('加载用户信息失败，请刷新重试'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  /// 加载统计数据
  Future<void> _loadStats() async {
    try {
      final stats = await PredictionService.getPredictionStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('加载统计数据失败: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  /// 导航到编辑资料页面
  Future<void> _navigateToEditProfile() async {
    if (!AuthService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先登录'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 检查是否正在加载
    if (_isLoadingUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('用户信息正在加载中，请稍后重试'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 即使昵称为空，也允许编辑
    if (_currentUser == null) {
      // 尝试重新加载
      await _loadUserData();
      
      if (_currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法加载用户信息，请退出重试'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    debugPrint('准备编辑用户: ${_currentUser!.email}');
    
    // 导航到编辑页面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentNickname: _currentUser!.nickname ?? '',
          currentAvatarUrl: _currentUser!.avatarUrl,
          onProfileUpdated: () async {
            await _loadUserData(); // 重新加载用户数据
          },
        ),
      ),
    );
    
    if (result == true) {
      await _loadUserData();
    }
  }

  /// 格式化日期
  String _formatDate(DateTime? date) {
    if (date == null) return '未知';
    return '${date.year}年${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    // 如果用户信息还在加载
    if (_isLoadingUser) {
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
              Text('加载用户信息中...'),
            ],
          ),
        ),
      );
    }

    // 统计数据加载状态显示
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
                _isLoadingUser = true;
              });
              _loadUserData();
              _loadStats();
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
            _buildUserInfoCard(context),

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
              onTap: _navigateToEditProfile,
            ),
            _buildFunctionItem(
              context,
              icon: Icons.notifications,
              title: '通知设置',
              subtitle: '管理预言到期提醒',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('通知设置功能开发中...'),
                    backgroundColor: Colors.orange,
                  ),
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
                  const SnackBar(
                    content: Text('帮助与反馈功能开发中...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ========== 退出登录按钮 ==========
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _logout();
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
  Widget _buildUserInfoCard(BuildContext context) {
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
            GestureDetector(
              onTap: _navigateToEditProfile,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: _buildUserAvatar(),
              ),
            ),
            const SizedBox(width: 20),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.nickname?.isNotEmpty == true
                        ? _currentUser!.nickname!
                        : (_currentUser?.email?.split('@').first ?? '用户'),  // 使用邮箱前缀作为昵称
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? '未设置邮箱',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (_currentUser?.createdAt != null)
                    Text(
                      '加入时间: ${_formatDate(_currentUser?.createdAt)}',
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
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit, size: 20),
              tooltip: '编辑个人资料',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar() {
    if (_currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _currentUser!.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 40,
      color: Colors.blue.shade600,
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
                    color: color.withOpacity(0.1),
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

  /// 退出登录
  Future<void> _logout() async {
    try {
      await AuthService.logout();
      // 导航到登录页面
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('退出登录失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}