// lib/utils/page_transitions.dart
import 'package:flutter/material.dart';

/// 页面转场动画类型
enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
}

/// 自定义页面路由
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Duration duration;

  CustomPageRoute({
    required this.page,
    this.transitionType = TransitionType.slide,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getTransition(
              animation,
              secondaryAnimation,
              child,
              transitionType,
            );
          },
        );

  static Widget _getTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
  ) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case TransitionType.slide:
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// 导航扩展方法
extension NavigationExtensions on BuildContext {
  /// 淡入导航
  Future<T?> fadeToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: TransitionType.fade,
      ),
    );
  }

  /// 滑动导航
  Future<T?> slideToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: TransitionType.slide,
      ),
    );
  }

  /// 缩放导航
  Future<T?> scaleToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: TransitionType.scale,
      ),
    );
  }

  /// 旋转导航
  Future<T?> rotateToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      CustomPageRoute(
        page: page,
        transitionType: TransitionType.rotation,
      ),
    );
  }
}

/// Hero 动画包装器
class HeroWrapper extends StatelessWidget {
  final String tag;
  final Widget child;

  const HeroWrapper({
    Key? key,
    required this.tag,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}