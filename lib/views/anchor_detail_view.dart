import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/anchor_model.dart';
import '../utils/app_theme.dart';

class AnchorDetailView extends StatefulWidget {
  final AnchorModel anchor;
  
  const AnchorDetailView({Key? key, required this.anchor}) : super(key: key);

  @override
  State<AnchorDetailView> createState() => _AnchorDetailViewState();
}

class _AnchorDetailViewState extends State<AnchorDetailView> {
  int _currentImageIndex = 0;

  static const Map<String, String> _moodEmojis = {
    '开心': '😊', '平静': '😌', '激动': '🤩',
    '难过': '😢', '焦虑': '😰', '疲惫': '😴',
  };
  
  static const Map<String, String> _weatherEmojis = {
    '晴天': '☀️', '多云': '⛅', '阴天': '☁️',
    '雨天': '🌧️', '雪天': '❄️', '雾天': '🌫️',
  };

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

  // 图片画廊
  Widget _buildImageGallery() {
    if (widget.anchor.imagePaths.isEmpty) return const SizedBox();
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // 图片轮播
        PageView.builder(
          itemCount: widget.anchor.imagePaths.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            return Image.file(
              File(widget.anchor.imagePaths[index]),
              fit: BoxFit.cover,
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