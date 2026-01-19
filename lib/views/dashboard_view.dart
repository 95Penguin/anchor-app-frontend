// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import '../widgets/radar_chart_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> 
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  bool _showFullRadar = false;

  // 每日一言
  final List<String> _dailyQuotes = [
    '每一个当下,都值得被铭记',
    '时光不语,锚点不忘',
    '成长的痕迹,由你书写',
    '投下锚点,让回忆有迹可循',
    '生活的精彩,藏在每个瞬间',
    '记录今天,成就明天',
  ];

  String get _todayQuote {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
  }

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;
    final stats = provider.getStatistics();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 背景层
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE0B2),
                  Color(0xFFFFF9C4),
                  Color(0xFFFFF5E1),
                ],
              ),
            ),
          ),

          // 装饰层
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentWarmOrange.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    )
                  ],
                ),
              ),
            ),
          ),

          // 人物立绘
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 10 + _breathAnimation.value,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    height: screenHeight * 0.9,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),

          // 左上角 HUD
          Positioned(
            top: 60,
            left: 20,
            child: _buildStatusHUD(user),
          ),

          // 右上角 HUD
          Positioned(
            top: 60,
            right: 20,
            child: _buildMiniRadar(user),
          ),

          // 每日一言
          Positioned(
            top: 170,
            left: 20,
            right: 20,
            child: _buildDailyQuote(),
          ),

          // 统计卡片
          Positioned(
            top: 240,
            left: 20,
            right: 20,
            child: _buildStatsCards(stats),
          ),

          // 全屏雷达图弹窗
          if (_showFullRadar) _buildFullRadarOverlay(user),
        ],
      ),
    );
  }

  Widget _buildStatusHUD(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppTheme.paperColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textBrown.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textBrown.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: const TextStyle(
              color: AppTheme.textBrown,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentWarmOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LV.${user.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: user.getExpProgress(),
                    backgroundColor: AppTheme.textBrown.withOpacity(0.05),
                    color: AppTheme.accentWarmOrange,
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRadar(UserModel user) {
    return GestureDetector(
      onTap: () => setState(() => _showFullRadar = true),
      child: Container(
        width: 85,
        height: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.paperColor.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.textBrown.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textBrown.withOpacity(0.1),
              blurRadius: 15,
            )
          ],
        ),
        child: RadarChartWidget(attributes: user.attributes, isMini: true),
      ),
    );
  }

  Widget _buildDailyQuote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentWarmOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppTheme.accentWarmOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _todayQuote,
              style: const TextStyle(
                color: AppTheme.textBrown,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '连续打卡',
            '${stats['currentStreak']}天',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '本周记录',
            '${stats['weekAnchors']}次',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildFullRadarOverlay(UserModel user) {
    return GestureDetector(
      onTap: () => setState(() => _showFullRadar = false),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            width: 320,
            height: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWarm,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.accentWarmOrange.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  "属性详情",
                  style: TextStyle(
                    color: AppTheme.textBrown,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: RadarChartWidget(attributes: user.attributes)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _showFullRadar = false),
                  child: const Text(
                    "返回手册",
                    style: TextStyle(color: AppTheme.accentWarmOrange, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}