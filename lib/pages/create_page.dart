// create_page.dart
// 版本: V0.6.5
// 创建日期: 2026-04-10
// 修改日期: 2026-04-13
// 修改目的: 修复编辑功能的构造函数参数问题
import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/prediction_service.dart';

class CreatePage extends StatefulWidget {
  final Prediction? prediction; // 如果是编辑模式，传入prediction
  
  const CreatePage({super.key, this.prediction});
  
  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  
  // 标签状态
  String? _selectedCategory;
  final List<String> _categories = [
    '工作', '生活', '学习', '健康', '财务', '娱乐', '其他'
  ];
  
  bool _isCreating = false;
  bool _isEditingMode = false;
  
  @override
  void initState() {
    super.initState();
    
    _isEditingMode = widget.prediction != null;
    
    if (_isEditingMode) {
      // 编辑模式：用预测数据填充表单
      _titleController.text = widget.prediction!.title;
      _contentController.text = widget.prediction!.description;
      _selectedDate = widget.prediction!.verificationDate;
      
      // 设置标签
      if (widget.prediction!.tags.isNotEmpty) {
        _selectedCategory = widget.prediction!.tags.first;
      }
    } else {
      // 创建模式：使用默认值
      _selectedDate = DateTime.now().add(const Duration(days: 7));
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
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
  
  // 提交预言的方法
  Future<void> _submitPrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入预言标题')),
      );
      return;
    }
    
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
      if (_isEditingMode && widget.prediction != null) {
        // 编辑模式：使用 copyWith 方法更新预言
        final updatedPrediction = widget.prediction!.copyWith(
          title: title,
          description: content,
          verificationDate: _selectedDate,
          tags: _selectedCategory != null ? [_selectedCategory!] : [],
          updatedAt: DateTime.now(),
        );
        
        await PredictionService.updatePrediction(updatedPrediction);
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('预言更新成功！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 创建模式：新增预言
        await PredictionService.addPrediction(
          title: title,
          content: content,
          dueDate: _selectedDate,
          tag: _selectedCategory ?? 'general',
        );
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('预言创建成功！')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditingMode ? '更新失败: $e' : '创建失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditingMode ? '编辑预言' : '新建预言'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                _isEditingMode ? '编辑你的预言' : '写下你的预言',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _isEditingMode ? '修改预言的内容和到期时间' : '清晰地描述你预测会发生的事情',
                style: const TextStyle(color: Colors.grey),
              ),
              
              const SizedBox(height: 24),
              
              // 预言标题输入框
              TextFormField(
                controller: _titleController,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: '预言标题',
                  hintText: '例如：明天下雨',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入预言标题';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 内容输入框
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '预言详情',
                  hintText: '详细描述你的预言，例如：\n我预测明天会下雨\n我预测上证指数4月1日会到3400点',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入预言内容';
                  }
                  return null;
                },
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
              
              // 标签选择区域
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '选择分类（可选）',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  
                  // 分类标签列表
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      return ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 8),
                  const Text(
                    '选择一个分类可以帮助你更好地组织预言',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              
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
                      : Text(
                          _isEditingMode ? '保存更改' : '发布预言',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}