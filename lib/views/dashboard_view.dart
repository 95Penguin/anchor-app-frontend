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

  @override
  void initState() {
    super.initState();
    // 呼吸动画: 2.5秒一个来回
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // 调整浮动幅度为 15 像素
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景层: 暖色调渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE0B2), // 浅橘
                  Color(0xFFFFF9C4), // 浅黄
                  Color(0xFFFFF5E1), // 奶油
                ],
              ),
            ),
          ),

          // 2. 装饰层: 底部光晕 (增强角色站立感)
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

          // 3. 人物立绘层 (带呼吸动画)
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Positioned(
                // 调低 bottom，让立绘“踩”在底部导航栏上
                bottom: 10 + _breathAnimation.value, 
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    height: screenHeight * 0.9, // 稍微增大立绘，填充卡片撤掉后的空白
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),

          // 4. 左上角 HUD: 角色状态
          Positioned(
            top: 60,
            left: 20,
            child: _buildStatusHUD(user),
          ),

          // 5. 右上角 HUD: 迷你雷达
          Positioned(
            top: 60,
            right: 20,
            child: _buildMiniRadar(user),
          ),

          // 6. 全屏雷达图弹窗 (点击右上角触发)
          if (_showFullRadar) _buildFullRadarOverlay(user),
        ],
      ),
    );
  }

  // 构建状态栏 HUD
  Widget _buildStatusHUD(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppTheme.paperColor.withOpacity(0.9), // 使用羊皮纸色，高对比度
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

  // 构建迷你雷达 HUD
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

  // 构建全屏雷达图弹窗
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