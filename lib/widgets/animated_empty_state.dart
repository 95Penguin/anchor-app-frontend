// lib/widgets/animated_empty_state.dart
import 'package:flutter/material.dart';

class AnimatedEmptyState extends StatefulWidget {
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;

  const AnimatedEmptyState({
    Key? key,
    required this.accentColor,
    this.title = '时间线空空如也',
    this.subtitle = '快去投下第一个锚点吧!',
    this.icon = Icons.anchor,
  }) : super(key: key);

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 浮动动画
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 淡入动画
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 浮动图标
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 80,
                      color: widget.accentColor.withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // 标题
            Text(
              widget.title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // 副标题
            Text(
              widget.subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            // 提示箭头动画
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value / 2),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 32,
                    color: widget.accentColor.withOpacity(0.4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}