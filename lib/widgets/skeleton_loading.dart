// lib/widgets/skeleton_loading.dart
import 'package:flutter/material.dart';

/// 骨架屏加载动画
class SkeletonLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const SkeletonLoading({
    Key? key,
    required this.child,
    this.isLoading = true,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 骨架容器
class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonContainer({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// 骨架卡片
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SkeletonLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            const SkeletonContainer(
              width: double.infinity,
              height: 140,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(height: 12),
            // 标题
            const SkeletonContainer(
              width: 200,
              height: 20,
            ),
            const SizedBox(height: 8),
            // 时间
            const SkeletonContainer(
              width: 100,
              height: 14,
            ),
            const SizedBox(height: 12),
            // 内容
            const SkeletonContainer(
              width: double.infinity,
              height: 14,
            ),
            const SizedBox(height: 6),
            const SkeletonContainer(
              width: double.infinity,
              height: 14,
            ),
            const SizedBox(height: 6),
            SkeletonContainer(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 14,
            ),
            const SizedBox(height: 12),
            // 底部标签
            Row(
              children: [
                const SkeletonContainer(width: 80, height: 20),
                const Spacer(),
                const SkeletonContainer(width: 50, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 骨架列表
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({Key? key, this.itemCount = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}