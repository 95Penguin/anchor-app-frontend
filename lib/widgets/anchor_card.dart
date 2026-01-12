import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:anchors/models/anchor_model.dart';
import 'package:anchors/utils/app_theme.dart';

class AnchorCard extends StatelessWidget {
  final AnchorModel anchor;
  final bool showFull;

  const AnchorCard({Key? key, required this.anchor, this.showFull = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 使用装饰容器代替系统 Card，获得更细腻的控制
      decoration: BoxDecoration(
        color: AppTheme.paperColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textBrown.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textBrown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 【关键】：让高度根据内容自动收缩
          children: [
            // 1. 顶部艺术占位区 (模拟相片边缘)
            _buildTopVisual(),

            // 2. 文字内容区
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题与日期
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          anchor.title,
                          style: const TextStyle(
                            color: AppTheme.textBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MM/dd').format(anchor.createdAt),
                        style: const TextStyle(color: AppTheme.textLightBrown, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // 正文内容：瀑布流的核心是这里不设固定高度
                  Text(
                    anchor.content,
                    maxLines: showFull ? null : 4, // 列表模式全显，网格模式最多4行
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textBrown.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // 3. 底部信息：位置与 XP 徽章
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.accentWarmOrange),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          anchor.location,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textLightBrown),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // XP 徽章
                      _buildXPBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 修改后的视觉区域
  Widget _buildTopVisual() {
    // 逻辑：如果没有图片，我们就把高度设得很小，作为一个装饰线条
    bool hasImage = anchor.imagePath != null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // 有图显示 120/80 高度，无图只显示 6 像素高度的色带
      height: hasImage ? (showFull ? 120 : 80) : 6, 
      width: double.infinity,
      decoration: BoxDecoration(
        // 如果没图，我们就用亮眼的橘色作为顶部的“属性封条”
        color: hasImage 
            ? AppTheme.accentWarmOrange.withOpacity(0.05) 
            : AppTheme.accentWarmOrange.withOpacity(0.8),
        image: hasImage
            ? DecorationImage(image: AssetImage(anchor.imagePath!), fit: BoxFit.cover)
            : null,
      ),
      child: hasImage && anchor.imagePath == null
          ? Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accentWarmOrange.withOpacity(0.2),
                size: 24,
              ),
            )
          : null,
    );
  }

  // 属性增益小徽章
  Widget _buildXPBadge() {
    final int totalPoints = anchor.attributeDelta.getTotalPoints();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentWarmOrange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "+$totalPoints",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}