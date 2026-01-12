import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../models/user_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // 初始化数据
    final user = Provider.of<AppProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age.toString());
    _bioController = TextEditingController(text: user.bio);
  }

  void _saveProfile() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.updateUserProfile(
      _nameController.text,
      int.tryParse(_ageController.text) ?? provider.user.age,
      _bioController.text,
    );
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('角色存档已同步', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.textBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('角色档案'),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle : Icons.edit_note,
              color: AppTheme.accentWarmOrange,
              size: 30,
            ),
            onPressed: () => _isEditing ? _saveProfile() : setState(() => _isEditing = true),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        // 设置水平间距，确保不贴边，与时间轴保持一致
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          // 【核心修复】：stretch 强制子组件（卡片）占满屏幕宽度
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 头像区域 (包裹在 Center 里防止被横向拉伸)
            Center(child: _buildAvatarSection(user)),
            const SizedBox(height: 40),

            // 2. 基础设定
            _buildSectionTitle("基础设定"),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildGameInput("姓名", _nameController, Icons.person_outline),
                    const SizedBox(height: 20),
                    _buildGameInput("年龄", _ageController, Icons.cake_outlined, isNumber: true),
                    const SizedBox(height: 20),
                    _buildGameInput("座右铭", _bioController, Icons.format_quote_outlined, maxLines: 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. 数值面板
            _buildSectionTitle("数值面板"),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: user.attributes.toMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 35,
                            child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBrown)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (entry.value % 100) / 100,
                                backgroundColor: AppTheme.textBrown.withOpacity(0.05),
                                color: AppTheme.accentWarmOrange,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text("${entry.value}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentWarmOrange)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. 其他信息 (这些磁贴也会跟随 Column 自动撑开)
            _buildSimpleTile(Icons.info_outline, "版本信息", "Anchors v1.0.0"),
            const SizedBox(height: 12),
            _buildSimpleTile(Icons.help_outline, "使用帮助", "每一次投掷都是一次成长"),
            
            const SizedBox(height: 60), 
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(UserModel user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.accentWarmOrange.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppTheme.accentWarmOrange.withOpacity(0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0] : "旅",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.textBrown),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "等级 ${user.level} 冒险者",
          style: const TextStyle(color: AppTheme.accentWarmOrange, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textBrown),
      ),
    );
  }

  Widget _buildGameInput(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      // 核心修复：显式文字颜色
      style: const TextStyle(color: AppTheme.textBrown, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textLightBrown),
        prefixIcon: Icon(icon, color: AppTheme.accentWarmOrange, size: 22),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.transparent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textBrown.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textLightBrown, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBrown)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textLightBrown)),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}