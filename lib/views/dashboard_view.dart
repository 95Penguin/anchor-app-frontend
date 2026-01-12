// ==================== views/dashboard_view.dart ====================
// 放在 lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 必须有这个，否则不认识 Provider
import 'package:anchors/providers/app_provider.dart'; // 引用你的数据管理
import 'package:anchors/utils/app_theme.dart'; // 引用你的主题颜色
import 'package:anchors/widgets/radar_chart_widget.dart'; // 引用雷达图
import 'package:anchors/widgets/anchor_card.dart'; // 引用卡片

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('锚点 - 主页', style: TextStyle(color: AppTheme.accentGreen)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 角色信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.accentGreen,
                          child: Text(
                            user.name[0],
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Lv.${user.level} | ${user.age}岁',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 经验进度条
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EXP: ${user.getExperience()} / ${user.getExpForNextLevel()}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.accentGreen),
                            ),
                            Text(
                              '${(user.getExpProgress() * 100).toInt()}%',
                              style: const TextStyle(fontSize: 12, color: AppTheme.accentPurple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: user.getExpProgress(),
                          backgroundColor: Colors.grey[800],
                          color: AppTheme.accentGreen,
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 属性雷达图
            const Text(
              '属性雷达图',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RadarChartWidget(attributes: user.attributes),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 最近锚点
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近的锚点',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                ),
                Text(
                  '共 ${provider.anchors.length} 个',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...provider.getRecentAnchors(3).map((anchor) => AnchorCard(anchor: anchor)),
            if (provider.anchors.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    '还没有锚点\n去"投掷"页面创建第一个吧!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
