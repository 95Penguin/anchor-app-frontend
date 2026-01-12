import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/anchor_card.dart';

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

  @override
  void initState() {
    super.initState();
    // 呼吸动画控制
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE0B2), Color(0xFFFFF9C4), Color(0xFFFFF5E1)],
              ),
            ),
          ),

          // 2. 人物立绘层
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 50 + _breathAnimation.value,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    height: screenHeight * 0.85,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),

          // 3. 左上角 HUD
          Positioned(
            top: 60,
            left: 20,
            child: _buildStatusHUD(user),
          ),

          // 4. 右上角迷你雷达
          Positioned(
            top: 60,
            right: 20,
            child: _buildMiniRadar(user),
          ),

          // 5. 底部卡片流
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildBottomCards(provider),
          ),

          // 6. 全屏雷达图弹窗
          if (_showFullRadar) _buildFullRadarOverlay(user),
        ],
      ),
    );
  }

  Widget _buildStatusHUD(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textBrown.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: AppTheme.textBrown.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.name, 
            style: const TextStyle(color: AppTheme.textBrown, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              value: user.getExpProgress(),
              backgroundColor: AppTheme.textBrown.withOpacity(0.05),
              color: AppTheme.accentWarmOrange,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('Lv.${user.level} 冒险者', 
            style: const TextStyle(color: AppTheme.accentWarmOrange, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMiniRadar(UserModel user) {
    return GestureDetector(
      onTap: () => setState(() => _showFullRadar = true),
      child: Container(
        width: 80, height: 80,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.textBrown.withOpacity(0.1), blurRadius: 10)],
        ),
        child: RadarChartWidget(attributes: user.attributes, isMini: true),
      ),
    );
  }

  Widget _buildBottomCards(AppProvider provider) {
    final recent = provider.getRecentAnchors(3);
    if (recent.isEmpty) return const SizedBox();

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recent.length,
        itemBuilder: (context, index) => Container(
          width: 280,
          margin: const EdgeInsets.only(right: 15),
          child: AnchorCard(anchor: recent[index]),
        ),
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
            width: 320, height: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWarm,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Text("属性详情", style: TextStyle(color: AppTheme.textBrown, fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(child: RadarChartWidget(attributes: user.attributes)),
                TextButton(
                  onPressed: () => setState(() => _showFullRadar = false),
                  child: const Text("返回手册", style: TextStyle(color: AppTheme.accentWarmOrange)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}