// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/prediction_service.dart';
import '../widgets/prediction_card.dart';
import 'create_page.dart';
import 'detail_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Prediction> _predictions = [];
  bool _isLoading = true;

  // ========== V0.4 新增：筛选与搜索状态 ==========
  String _searchKeyword = ''; // 搜索关键词
  String _selectedStatus = 'all'; // 选中的状态：'all', 'pending', 'judging', 'success', 'failure'
  bool _showSearchBar = false; // 是否显示搜索框
  
  // 修复：使用持久的 TextEditingController
  late final TextEditingController _searchController;
  // ============================================

  @override
  void initState() {
    super.initState();
    
    // 初始化搜索控制器
    _searchController = TextEditingController(text: _searchKeyword);
    
    _initializeApp();
  }

  @override
  void dispose() {
    // 清理资源
    _searchController.dispose();
    super.dispose();
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

  // ========== V0.4 新增：过滤预言列表的方法 ==========

  /// 获取过滤后的预言列表
  List<Prediction> get _filteredPredictions {
    if (_predictions.isEmpty) return [];

    return _predictions.where((prediction) {
      // 1. 状态筛选
      final bool statusMatches = _selectedStatus == 'all' ||
          prediction.status == _selectedStatus;

      // 2. 搜索关键词筛选
      final bool keywordMatches = _searchKeyword.isEmpty ||
          prediction.content
              .toLowerCase()
              .contains(_searchKeyword.toLowerCase());

      return statusMatches && keywordMatches;
    }).toList();
  }

  /// 获取当前状态筛选器的显示文本
  String get _selectedStatusText {
    switch (_selectedStatus) {
      case 'all':
        return '全部';
      case 'pending':
        return '待验证';
      case 'judging':
        return '待裁决';
      case 'success':
        return '预言成功';
      case 'failure':
        return '预言失败';
      default:
        return '全部';
    }
  }

  /// 重置所有筛选条件
  void _resetFilters() {
    setState(() {
      _searchKeyword = '';
      _selectedStatus = 'all';
      _showSearchBar = false;
      _searchController.text = ''; // 清空搜索框
    });
  }
  
  /// 处理搜索文本变化
  void _onSearchTextChanged(String value) {
    setState(() {
      _searchKeyword = value;
    });
  }
  
  /// 清空搜索框
  void _clearSearch() {
    setState(() {
      _searchKeyword = '';
      _searchController.clear();
    });
  }

  // ============================================

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
          // 搜索按钮 - 点击显示/隐藏搜索框
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _clearSearch(); // 隐藏搜索框时清空搜索
                }
              });
            },
            tooltip: '搜索预言',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
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
          : Column(
              children: [
                // ========== V0.4 新增：筛选与搜索区域 ==========
                if (_showSearchBar) _buildSearchBar(),
                _buildFilterSection(),
                // ============================================

                Expanded(
                  child: _filteredPredictions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filteredPredictions.length,
                          itemBuilder: (context, index) {
                            final prediction = _filteredPredictions[index];
                            return PredictionCard(
                              prediction: prediction,
                              onTap: () => _navigateToDetailPage(prediction.id),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePage,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ========== V0.4 新增：UI组件方法 ==========

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController, // 使用持久的controller
              onChanged: _onSearchTextChanged,
              autofocus: true, // 自动获取焦点
              decoration: InputDecoration(
                hintText: '搜索预言内容...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选器区域
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 筛选器标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '筛选: $_selectedStatusText',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_searchKeyword.isNotEmpty || _selectedStatus != 'all')
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text(
                    '重置',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 状态筛选器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('全部', 'all', Colors.blue),
                const SizedBox(width: 8),
                _buildStatusChip('待验证', 'pending', Colors.grey),
                const SizedBox(width: 8),
                _buildStatusChip('待裁决', 'judging', Colors.orange),
                const SizedBox(width: 8),
                _buildStatusChip('预言成功', 'success', Colors.green),
                const SizedBox(width: 8),
                _buildStatusChip('预言失败', 'failure', Colors.red),
              ],
            ),
          ),

          // 搜索结果统计
          if (_searchKeyword.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '找到 ${_filteredPredictions.length} 条相关预言',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建状态筛选芯片
  Widget _buildStatusChip(String label, String status, Color color) {
    final bool isSelected = _selectedStatus == status;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : 'all';
        });
      },
      selectedColor: color,
      backgroundColor: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  /// 构建空状态提示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_searchKeyword.isNotEmpty || _selectedStatus != 'all')
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300)
          else
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade300),

          const SizedBox(height: 16),

          Text(
            _searchKeyword.isNotEmpty
                ? '没有找到包含"$_searchKeyword"的预言'
                : (_selectedStatus != 'all'
                    ? '没有状态为"$_selectedStatusText"的预言'
                    : '还没有任何预言'),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            _searchKeyword.isNotEmpty || _selectedStatus != 'all'
                ? '尝试使用其他关键词，或点击"重置"查看所有预言'
                : '点击下方按钮创建第一个预言吧！',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          if (_searchKeyword.isNotEmpty || _selectedStatus != 'all')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: OutlinedButton(
                onPressed: _resetFilters,
                child: const Text('重置筛选条件'),
              ),
            ),
        ],
      ),
    );
  }
}