// lib/views/statistics_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final stats = provider.getStatistics();
    final trendData = provider.getAttributeTrendData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('成长分析'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 概览卡片
          _buildOverviewCards(stats),
          const SizedBox(height: 24),

          // 属性增长趋势图
          const Text(
            '属性增长趋势',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBrown,
            ),
          ),
          const SizedBox(height: 12),
          if (trendData.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: _buildTrendChart(trendData),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 最常访问地点
          const Text(
            '活动分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBrown,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatRow('最常去的地点', stats['topLocation'], Icons.location_on),
                  const Divider(height: 32),
                  _buildStatRow('最常见的心情', stats['topMood'], Icons.mood),
                  const Divider(height: 32),
                  _buildStatRow('总锚点数', '${stats['totalAnchors']}', Icons.anchor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 时间分布
          const Text(
            '记录频率',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBrown,
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

  Widget _buildOverviewCards(Map<String, dynamic> stats) {
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
                  const Icon(Icons.anchor, color: AppTheme.accentWarmOrange, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    '${stats['totalAnchors']}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentWarmOrange,
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

  Widget _buildTrendChart(List<Map<String, dynamic>> trendData) {
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
            color: AppTheme.accentWarmOrange,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.accentWarmOrange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentWarmOrange, size: 24),
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