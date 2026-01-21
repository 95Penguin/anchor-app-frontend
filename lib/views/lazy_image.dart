// lib/widgets/lazy_image.dart
import 'dart:io';
import 'package:flutter/material.dart';

/// 懒加载图片组件
class LazyImage extends StatefulWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyImage({
    Key? key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return widget.errorWidget ??
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
            ),
          );
    }

    return Image.file(
      File(widget.imagePath),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        
        if (frame == null) {
          // 图片还在加载中，显示占位符
          return widget.placeholder ??
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        }
        
        // 图片加载完成，添加淡入动画
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // 延迟设置错误状态，避免在 build 期间调用 setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _hasError = true);
          }
        });
        return widget.errorWidget ??
            Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
              ),
            );
      },
    );
  }
}

/// 缓存图片管理器
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  final Map<String, Image> _cache = {};
  static const int maxCacheSize = 50;

  Image? getImage(String path) {
    return _cache[path];
  }

  void cacheImage(String path, Image image) {
    if (_cache.length >= maxCacheSize) {
      // 移除最旧的缓存
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[path] = image;
  }

  void clearCache() {
    _cache.clear();
  }

  void removeImage(String path) {
    _cache.remove(path);
  }
}

/// 优化的图片列表项
class OptimizedImageListItem extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double height;

  const OptimizedImageListItem({
    Key? key,
    required this.imagePath,
    this.onTap,
    this.height = 140,
  }) : super(key: key);

  @override
  State<OptimizedImageListItem> createState() => _OptimizedImageListItemState();
}

class _OptimizedImageListItemState extends State<OptimizedImageListItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: LazyImage(
        imagePath: widget.imagePath,
        height: widget.height,
        fit: BoxFit.cover,
        placeholder: Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}