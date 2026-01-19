// lib/views/anchor_detail_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/anchor_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarm,
      body: CustomScrollView(
        slivers: [
          // 顶部图片区域（如果有照片）
          if (widget.anchor.imagePaths.isNotEmpty)
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppTheme.accentWarmOrange,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageGallery(),
              ),
            )
          else
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.backgroundWarm,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textBrown),
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBrown,
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
                      ),
                      if (widget.anchor.weather != null)
                        _buildInfoChip(
                          null,
                          '${_weatherEmojis[widget.anchor.weather!]} ${widget.anchor.weather}',
                        ),
                      if (widget.anchor.mood != null)
                        _buildInfoChip(
                          null,
                          '${_moodEmojis[widget.anchor.mood!]} ${widget.anchor.mood}',
                        ),
                      _buildInfoChip(
                        Icons.location_on,
                        widget.anchor.location,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 内容
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.paperColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.textBrown.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.anchor.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: AppTheme.textBrown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 照片网格（如果有多张照片）
                  if (widget.anchor.imagePaths.length > 1)
                    _buildPhotoGrid(),
                  
                  if (widget.anchor.imagePaths.length > 1)
                    const SizedBox(height: 24),
                  
                  // 属性增长信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentWarmOrange.withOpacity(0.1),
                          AppTheme.accentWarmOrange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppTheme.accentWarmOrange),
                        const SizedBox(width: 12),
                        Text(
                          '本次成长: +${widget.anchor.attributeDelta.getTotalPoints()} 经验值',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textBrown,
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
  Widget _buildImageGallery() {
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
                // 点击放大查看
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
                    color: AppTheme.accentWarmOrange.withOpacity(0.1),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: AppTheme.textLightBrown),
                          SizedBox(height: 8),
                          Text('图片加载失败', style: TextStyle(color: AppTheme.textLightBrown)),
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
  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '所有照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBrown,
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
                      color: AppTheme.accentWarmOrange.withOpacity(0.1),
                      child: const Icon(Icons.broken_image, color: AppTheme.textLightBrown),
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

  Widget _buildInfoChip(IconData? icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textBrown.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppTheme.accentWarmOrange),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textBrown,
            ),
          ),
        ],
      ),
    );
  }
}