import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

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
    // 初始化时获取当前用户信息
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
      const SnackBar(content: Text('角色存档已更新'), backgroundColor: AppTheme.accentGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('角色信息', style: TextStyle(color: AppTheme.accentGreen)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit_note, color: AppTheme.accentGreen, size: 28),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 头像
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.accentGreen.withOpacity(0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : "?",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.accentPurple,
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 基本信息表单
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: "角色名",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "年龄",
                        prefixIcon: Icon(Icons.history_toggle_off),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
                      enabled: _isEditing,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "座右铭",
                        prefixIcon: Icon(Icons.auto_awesome_mosaic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 属性数值展示
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(" 属性详情", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: user.attributes.toMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (entry.value % 100) / 100,
                              backgroundColor: Colors.black26,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text("${entry.value}", style: const TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 危险区域/其他
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.grey),
                    title: const Text("关于 Anchors"),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    title: const Text("清除所有本地记录"),
                    onTap: () {
                      // 这里可以以后接入 Provider 的清除方法
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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