// lib/views/statistics_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({Key? key}) : super(key: key);

  Color _getAccentColor(ThemeProvider themeProvider) {
    switch (themeProvider.currentTheme) {
      case AppThemeMode.warm:
        return const Color(0xFFFF8A65);
      case AppThemeMode.ocean:
        return const Color(0xFF0097A7);
      case AppThemeMode.forest:
        return const Color(0xFF4CAF50);
      case AppThemeMode.dark:
        return const Color(0xFFFF8A65);
      case AppThemeMode.custom:
        return themeProvider.customColor;
      default:
        return const Color(0xFFFF8A65);
    }
}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = _getAccentColor(themeProvider);
    final stats = provider.getStatistics();
    final trendData = provider.getAttributeTrendData();
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('成长分析'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 概览卡片
          _buildOverviewCards(stats, accentColor),
          const SizedBox(height: 24),

          // 【新增】成就进度条
          _buildAchievementProgress(stats, user, accentColor),
          const SizedBox(height: 24),

          // 属性增长趋势图
          Text(
            '属性增长趋势',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          if (trendData.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _buildTrendChart(trendData, accentColor),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 活动分析
          Text(
            '活动分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatRow('最常去的地点', stats['topLocation'], Icons.location_on, accentColor),
                  const Divider(height: 32),
                  _buildStatRow('最常见的心情', stats['topMood'], Icons.mood, accentColor),
                  const Divider(height: 32),
                  _buildStatRow('总锚点数', '${stats['totalAnchors']}', Icons.anchor, accentColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 时间分布
          Text(
            '记录频率',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFrequencyCard(
                  '本周',
                  stats['weekAnchors'],
                  Icons.calendar_view_week,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFrequencyCard(
                  '本月',
                  stats['monthAnchors'],
                  Icons.calendar_month,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: const Color(0xFFFFE0B2),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    '${stats['currentStreak']}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text(
                    '连续打卡',
                    style: TextStyle(
                      color: AppTheme.textBrown,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: const Color(0xFFB2EBF2),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.anchor, color: accentColor, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    '${stats['totalAnchors']}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const Text(
                    '总锚点数',
                    style: TextStyle(
                      color: AppTheme.textBrown,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 【新增】成就进度条
  Widget _buildAchievementProgress(Map<String, dynamic> stats, user, Color accentColor) {
    final achievements = [
      {
        'title': '新手启航',
        'current': stats['totalAnchors'],
        'target': 1,
        'icon': Icons.sailing,
      },
      {
        'title': '持之以恒',
        'current': stats['currentStreak'],
        'target': 7,
        'icon': Icons.local_fire_department,
      },
      {
        'title': '经验丰富',
        'current': stats['totalAnchors'],
        'target': 50,
        'icon': Icons.star,
      },
      {
        'title': '大师级别',
        'current': user.level,
        'target': 10,
        'icon': Icons.military_tech,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: accentColor, size: 24),
                const SizedBox(width: 12),
                const Text(
                  '成就进度',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...achievements.map((achievement) {
              final progress = (achievement['current'] as int) / (achievement['target'] as int);
              final isCompleted = progress >= 1.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          achievement['icon'] as IconData,
                          size: 20,
                          color: isCompleted ? accentColor : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            achievement['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isCompleted ? accentColor : Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          '${achievement['current']}/${achievement['target']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? accentColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress > 1.0 ? 1.0 : progress,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        color: isCompleted ? accentColor : Colors.grey,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<Map<String, dynamic>> trendData, Color accentColor) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trendData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                (entry.value['intelligence'] +
                    entry.value['strength'] +
                    entry.value['charisma'] +
                    entry.value['perception'] +
                    entry.value['willpower']).toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: accentColor,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: accentColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color accentColor) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textLightBrown,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyCard(String title, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textLightBrown,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}