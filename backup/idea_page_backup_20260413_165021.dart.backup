// idea_page.dart
// 版本: V0.1
// 创建日期: 2026-04-11
// 描述: 灵光一现记录页面，允许用户快速记录突然冒出的想法

import 'package:flutter/material.dart';
import '../services/prediction_service.dart';

class IdeaPage extends StatefulWidget {
  const IdeaPage({super.key});

  @override
  State<IdeaPage> createState() => _IdeaPageState();
}

class _IdeaPageState extends State<IdeaPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // 标签状态
  String? _selectedCategory;
  final List<String> _categories = [
    '工作', '生活', '学习', '健康', '财务', '娱乐', '其他'
  ];
  
  bool _isSaving = false;
  
  // 保存想法的方法
  Future<void> _saveIdea() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入想法标题')),
      );
      return;
    }
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入想法内容')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // 调用服务层方法，传入所有必需参数
      await PredictionService.addPrediction(
        title: title,
        content: content,
        dueDate: DateTime.now().add(const Duration(days: 30)), // 默认30天后到期
        tag: _selectedCategory ?? '其他',
      );
      
      // 返回主页并通知刷新
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('想法保存成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('灵光一现'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE4E7EB),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部装饰
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 64,
                        color: Colors.amber.shade500,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '捕捉你的灵感',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '快速记录突然冒出的想法',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 想法标题输入框
                TextFormField(
                  controller: _titleController,
                  maxLines: 1,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '想法标题',
                    hintText: '例如：一个新的应用创意',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入想法标题';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 内容输入框
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: '想法详情',
                    hintText: '详细描述你的想法...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入想法内容';
                    }
                    return null;
                  },
                ),
                
                // 标签选择区域
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择分类',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    
                    // 分类标签列表
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category 
                              ? Colors.white 
                              : Colors.grey.shade700,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveIdea,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '保存想法',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 提示信息
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 小贴士',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 保持简洁，抓住核心想法\n• 使用关键词标记重要信息\n• 定期回顾你的想法，可能会有新的灵感',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
