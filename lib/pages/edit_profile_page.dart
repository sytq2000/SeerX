// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
//import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final String currentNickname;
  final String? currentAvatarUrl;
  final Function() onProfileUpdated;

  const EditProfilePage({
    Key? key,
    required this.currentNickname,
    this.currentAvatarUrl,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  bool _isLoading = false;
  bool _isCheckingNickname = false;
  bool _isNicknameAvailable = true;
  String? _selectedAvatarUrl;
  String? _uploadedAvatarUrl;
  //bool _isUploading = false;

  // 默认头像列表
  final List<String> _defaultAvatars = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=1',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=2',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=3',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=4',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=5',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=6',
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _selectedAvatarUrl = widget.currentAvatarUrl;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _checkNicknameAvailability() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || nickname == widget.currentNickname) {
      return;
    }

    setState(() {
      _isCheckingNickname = true;
    });

    try {
      final isAvailable = await ProfileService.isNicknameAvailable(nickname);
      setState(() {
        _isNicknameAvailable = isAvailable;
      });

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('该昵称已被使用，请选择其他昵称'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查昵称失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingNickname = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nickname = _nicknameController.text.trim();
    final avatarUrl = _uploadedAvatarUrl ?? _selectedAvatarUrl;

    // 如果没有变化，直接返回
    if (nickname == widget.currentNickname && avatarUrl == widget.currentAvatarUrl) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    // 如果昵称变化了但未检查或不可用
    if (nickname != widget.currentNickname && !_isNicknameAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请先检查昵称是否可用'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ProfileService.updateProfile(
        nickname: nickname,
        avatarUrl: avatarUrl,
      );

      widget.onProfileUpdated();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('个人资料更新成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!_isLoading) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: '保存',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像选择部分
              _buildAvatarSection(),
              const SizedBox(height: 24.0),

              // 昵称输入部分
              _buildNicknameSection(),
              const SizedBox(height: 24.0),

              // 保存按钮
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '头像',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          '点击选择默认头像（后续版本将支持上传自定义头像）',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16.0),

        // 当前头像
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildAvatarImage(),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '当前头像',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),
        const Text(
          '默认头像选择',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),

        // 默认头像网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _defaultAvatars.length,
          itemBuilder: (context, index) {
            final avatarUrl = _defaultAvatars[index];
            final isSelected = _selectedAvatarUrl == avatarUrl;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatarUrl = avatarUrl;
                  _uploadedAvatarUrl = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    final currentUrl = _uploadedAvatarUrl ?? _selectedAvatarUrl ?? widget.currentAvatarUrl;
    
    if (currentUrl == null || currentUrl.isEmpty) {
      return Container(
        color: Colors.blue.shade100,
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.blue.shade600,
        ),
      );
    }

    return Image.network(
      currentUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.blue.shade100,
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.blue.shade600,
          ),
        );
      },
    );
  }

  Widget _buildNicknameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '昵称',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          '昵称是唯一的，其他用户将通过昵称找到您',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12.0),

        TextFormField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: '请输入昵称（2-20个字符）',
            border: const OutlineInputBorder(),
            suffixIcon: _isCheckingNickname
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _nicknameController.text.isNotEmpty &&
                        _nicknameController.text != widget.currentNickname
                    ? IconButton(
                        icon: Icon(
                          _isNicknameAvailable
                              ? Icons.check_circle
                              : Icons.error,
                          color: _isNicknameAvailable
                              ? Colors.green
                              : Colors.red,
                        ),
                        onPressed: _checkNicknameAvailability,
                        tooltip: '检查昵称是否可用',
                      )
                    : null,
          ),
          maxLength: 20,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '昵称不能为空';
            }
            if (value.trim().length < 2) {
              return '昵称至少需要2个字符';
            }
            if (value.trim().length > 20) {
              return '昵称最多20个字符';
            }
            return null;
          },
          onChanged: (value) {
            if (value.trim() != widget.currentNickname) {
              setState(() {
                _isNicknameAvailable = false;
              });
            } else {
              setState(() {
                _isNicknameAvailable = true;
              });
            }
          },
        ),

        const SizedBox(height: 8.0),
        if (_nicknameController.text != widget.currentNickname)
          Text(
            _isNicknameAvailable
                ? '✅ 昵称可用'
                : '⚠️ 昵称可能已被占用，请点击右侧按钮检查',
            style: TextStyle(
              fontSize: 12,
              color: _isNicknameAvailable ? Colors.green : Colors.orange,
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '保存修改',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}