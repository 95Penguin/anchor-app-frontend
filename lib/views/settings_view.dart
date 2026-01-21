// lib/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import 'custom_theme_editor.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 主题设置
          _buildSectionTitle('外观主题'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  themeProvider,
                  '暖色调',
                  AppThemeMode.warm,
                  const Color(0xFFFF8A65),
                ),
                _buildThemeOption(
                  context,
                  themeProvider,
                  '海洋蓝',
                  AppThemeMode.ocean,
                  const Color(0xFF0097A7),
                ),
                _buildThemeOption(
                  context,
                  themeProvider,
                  '森林绿',
                  AppThemeMode.forest,
                  const Color(0xFF4CAF50),
                ),
                // 自定义主题色入口
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: themeProvider.currentTheme == AppThemeMode.custom
                        ? themeProvider.customColor
                        : Colors.grey[300],
                    child: Icon(
                      Icons.palette,
                      color: themeProvider.currentTheme == AppThemeMode.custom
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                  title: const Text('自定义主题'),
                  subtitle: const Text('点击自定义颜色'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (themeProvider.currentTheme == AppThemeMode.custom)
                        const Icon(Icons.check, color: AppTheme.accentWarmOrange),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomThemeEditor(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('深色模式'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleDarkMode();
                  },
                  secondary: const Icon(Icons.dark_mode),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 通知设置
          _buildSectionTitle('通知提醒'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('每日提醒'),
                  subtitle: Text('在 ${_reminderTime.format(context)} 提醒您记录'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      await NotificationService.instance.scheduleDailyReminder(
                        _reminderTime.hour,
                        _reminderTime.minute,
                      );
                    } else {
                      await NotificationService.instance.cancelAllNotifications();
                    }
                    setState(() => _notificationsEnabled = value);
                  },
                  secondary: const Icon(Icons.notifications),
                ),
                if (_notificationsEnabled)
                  ListTile(
                    title: const Text('提醒时间'),
                    trailing: Text(
                      _reminderTime.format(context),
                      style: const TextStyle(
                        color: AppTheme.accentWarmOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (picked != null) {
                        setState(() => _reminderTime = picked);
                        await NotificationService.instance.scheduleDailyReminder(
                          picked.hour,
                          picked.minute,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 数据管理
          _buildSectionTitle('数据管理'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup, color: AppTheme.accentWarmOrange),
                  title: const Text('备份数据'),
                  subtitle: const Text('导出您的所有锚点记录'),
                  onTap: () => _exportData(appProvider),
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.blue),
                  title: const Text('分享应用'),
                  subtitle: const Text('向朋友推荐 Anchors'),
                  onTap: _shareApp,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('清除所有数据'),
                  subtitle: const Text('谨慎操作,此操作不可恢复'),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 关于
          _buildSectionTitle('关于'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('版本信息'),
                  subtitle: Text('Anchors v1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('使用帮助'),
                  onTap: () => _showHelpDialog(context),
                ),
                const ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('隐私政策'),
                  subtitle: Text('我们重视您的隐私'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textBrown,
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider provider,
    String title,
    AppThemeMode mode,
    Color color,
  ) {
    final isSelected = provider.currentTheme == mode;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
      title: Text(title),
      onTap: () {
        provider.setTheme(mode);
      },
    );
  }

  void _exportData(AppProvider provider) {
    final data = provider.exportData();
    Share.share(
      '我的 Anchors 数据:\n$data',
      subject: 'Anchors 数据导出',
    );
  }

  void _shareApp() {
    Share.share(
      '推荐一款记录生活的应用 - Anchors,投下锚点,让回忆不再漂流!',
      subject: '分享 Anchors',
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除?'),
        content: const Text('此操作将删除所有锚点记录和用户数据,且无法恢复。确定要继续吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 这里应该添加清除数据的逻辑
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('数据已清除'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              '确认清除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('使用帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📝 投掷锚点',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('点击"投掷"按钮,记录当下的感受和想法。每次投锚都会增加相应的属性值。'),
              SizedBox(height: 16),
              Text(
                '📊 查看属性',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('在主页点击右上角的雷达图,可以查看详细的属性分布。'),
              SizedBox(height: 16),
              Text(
                '🔍 搜索筛选',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('在时间轴页面,可以通过搜索框查找特定的锚点,或使用筛选功能按日期查看。'),
              SizedBox(height: 16),
              Text(
                '✨ 持续记录',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('每天投下一个锚点,积累经验,提升等级,见证自己的成长轨迹!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }
}