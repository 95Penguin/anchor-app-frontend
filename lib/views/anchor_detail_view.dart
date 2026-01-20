// lib/views/anchor_detail_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/anchor_model.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/image_viewer.dart';

class AnchorDetailView extends StatefulWidget {
  final AnchorModel anchor;
  
  const AnchorDetailView({Key? key, required this.anchor}) : super(key: key);

  @override
  State<AnchorDetailView> createState() => _AnchorDetailViewState();
}

class _AnchorDetailViewState extends State<AnchorDetailView> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  static const Map<String, String> _moodEmojis = {
    '开心': '😊', '平静': '😌', '激动': '🤩',
    '难过': '😢', '焦虑': '😰', '疲惫': '😴',
  };
  
  static const Map<String, String> _weatherEmojis = {
    '晴天': '☀️', '多云': '⛅', '阴天': '☁️',
    '雨天': '🌧️', '雪天': '❄️', '雾天': '🌫️',
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = _getAccentColor(themeProvider);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // 顶部图片区域（如果有照片）
          if (widget.anchor.imagePaths.isNotEmpty)
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: accentColor,
              iconTheme: IconThemeData(color: textColor),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageGallery(accentColor),
              ),
            )
          else
            SliverAppBar(
              pinned: true,
              backgroundColor: backgroundColor,
              elevation: 0,
              iconTheme: IconThemeData(color: textColor),
            ),
          
          // 内容区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    widget.anchor.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 时间、心情、天气
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        DateFormat('yyyy年MM月dd日 HH:mm').format(widget.anchor.createdAt),
                        textColor,
                        backgroundColor,
                      ),
                      if (widget.anchor.weather != null)
                        _buildInfoChip(
                          null,
                          '${_weatherEmojis[widget.anchor.weather!]} ${widget.anchor.weather}',
                          textColor,
                          backgroundColor,
                        ),
                      if (widget.anchor.mood != null)
                        _buildInfoChip(
                          null,
                          '${_moodEmojis[widget.anchor.mood!]} ${widget.anchor.mood}',
                          textColor,
                          backgroundColor,
                        ),
                      _buildInfoChip(
                        Icons.location_on,
                        widget.anchor.location,
                        textColor,
                        backgroundColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 内容
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.anchor.content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 照片网格（如果有多张照片）
                  if (widget.anchor.imagePaths.length > 1)
                    _buildPhotoGrid(textColor, accentColor),
                  
                  if (widget.anchor.imagePaths.length > 1)
                    const SizedBox(height: 24),
                  
                  // 属性增长信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.1),
                          accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: accentColor),
                        const SizedBox(width: 12),
                        Text(
                          '本次成长: +${widget.anchor.attributeDelta.getTotalPoints()} 经验值',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 顶部大图轮播
  Widget _buildImageGallery(Color accentColor) {
    if (widget.anchor.imagePaths.isEmpty) return const SizedBox();
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // 图片轮播
        PageView.builder(
          controller: _pageController,
          itemCount: widget.anchor.imagePaths.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewer(
                      imagePaths: widget.anchor.imagePaths,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Image.file(
                File(widget.anchor.imagePaths[index]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: accentColor.withOpacity(0.1),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('图片加载失败', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        
        // 图片指示器
        if (widget.anchor.imagePaths.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImageIndex + 1} / ${widget.anchor.imagePaths.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 底部照片网格
  Widget _buildPhotoGrid(Color textColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '所有照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: widget.anchor.imagePaths.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewer(
                      imagePaths: widget.anchor.imagePaths,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.anchor.imagePaths[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: accentColor.withOpacity(0.1),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData? icon, String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor.withOpacity(0.7)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}