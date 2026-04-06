// lib/pages/create_page.dart
import 'package:flutter/material.dart';
import '../services/prediction_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  // ========== V0.5 Day2 新增：标签状态 ==========
  String _selectedTag = ''; // 存储用户选择的标签，默认为空字符串
  final List<String> _suggestedTags = [
    '工作', '生活', '学习', '健康', '财务', '娱乐', '其他'
  ]; // 预设的常用标签建议
  // ============================================
  
  bool _isCreating = false;
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // ========== 修改后的提交方法 ==========
  Future<void> _submitPrediction() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入预言内容')),
      );
      return;
    }
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      // 调用服务层方法，传入标签
      await PredictionService.addPrediction(
        content, 
        _selectedDate,
        tag: _selectedTag.isEmpty ? null : _selectedTag, // 传入标签，空字符串转为null
      );
      
      // 返回主页并通知刷新
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('预言创建成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
  // ====================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建预言'),
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
            // 标题
            const Text(
              '写下你的预言',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              '清晰地描述你预测会发生的事情',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 24),
            
            // 内容输入框
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '例如：我预测明天会下雨\n我预测上证指数4月1日会到3400点',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 日期选择
            const Text(
              '预言到期时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
            
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              '选择验证这个预言是否实现的日期',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            
            // ========== V0.5 Day2 新增：标签选择区域 ==========
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择标签（可选）',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                // 标签建议列表
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestedTags.map((tag) {
                    return ChoiceChip(
                      label: Text(tag),
                      selected: _selectedTag == tag,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = selected ? tag : ''; // 点击已选中的标签可取消
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // 自定义标签输入（可选功能，如果时间充裕）
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _selectedTag = value; // 允许用户输入自定义标签
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: '或输入自定义标签...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
            // ============================================
            
            const SizedBox(height: 40),
            
            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _submitPrediction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '发布预言',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}