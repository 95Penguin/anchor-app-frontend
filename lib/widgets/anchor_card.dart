import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/anchor_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../views/edit_anchor_view.dart';
import '../views/anchor_detail_view.dart';

class AnchorCard extends StatelessWidget {
  final AnchorModel anchor;
  final bool showFull;

  const AnchorCard({Key? key, required this.anchor, this.showFull = false}) : super(key: key);

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
    return GestureDetector(
      // 【修改】单击跳转到详情页
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnchorDetailView(anchor: anchor),
          ),
        );
      },
      onLongPress: () => _showActionMenu(context),
      
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.paperColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textBrown.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 【优化】照片展示区域
              _buildPhotoSection(),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            anchor.title,
                            style: const TextStyle(
                              color: AppTheme.textBrown,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 心情和天气标签
                        if (anchor.weather != null)
                          Text(_weatherEmojis[anchor.weather!] ?? '', style: const TextStyle(fontSize: 14)),
                        if (anchor.weather != null && anchor.mood != null)
                          const SizedBox(width: 4),
                        if (anchor.mood != null)
                          Text(_moodEmojis[anchor.mood!] ?? '', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    
                    // 时间
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('MM/dd HH:mm').format(anchor.createdAt),
                        style: TextStyle(
                          color: AppTheme.textLightBrown.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 内容
                    Text(
                      anchor.content,
                      maxLines: showFull ? null : 3,
                      style: TextStyle(
                        color: AppTheme.textBrown.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 地点和经验值
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.accentWarmOrange),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            anchor.location,
                            style: const TextStyle(fontSize: 10, color: AppTheme.textLightBrown),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildXPBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 【优化】照片展示区域
  Widget _buildPhotoSection() {
    if (anchor.imagePaths.isEmpty) {
      // 没有照片时显示装饰条
      return Container(
        height: 4,
        width: double.infinity,
        color: AppTheme.accentWarmOrange.withOpacity(0.8),
      );
    }

    // 列表模式：显示第一张照片
    if (!showFull) {
      return Container(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(anchor.imagePaths.first),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.accentWarmOrange.withOpacity(0.1),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppTheme.textLightBrown, size: 40),
                  ),
                );
              },
            ),
            // 如果有多张照片，显示数量标识
            if (anchor.imagePaths.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.collections, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${anchor.imagePaths.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // 详情模式：显示多张照片横向滚动
    return Container(
      height: 200,
      child: anchor.imagePaths.length == 1
          ? Image.file(
              File(anchor.imagePaths.first),
              fit: BoxFit.cover,
              width: double.infinity,
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: anchor.imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == anchor.imagePaths.length - 1 ? 0 : 4,
                  ),
                  child: Image.file(
                    File(anchor.imagePaths[index]),
                    fit: BoxFit.cover,
                    width: 200,
                  ),
                );
              },
            ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWarm,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            
            const Text("锚点操作", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textBrown)),
            const SizedBox(height: 10),
            
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.edit_rounded, color: Colors.blue),
              ),
              title: const Text("修改这段记录", style: TextStyle(color: AppTheme.textBrown)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditAnchorView(anchor: anchor)));
              },
            ),
            
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              ),
              title: const Text("抹除这段回忆", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.paperColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("确定抹除？", style: TextStyle(color: AppTheme.textBrown)),
        content: const Text("一旦撤回，对应的属性成长也会受到影响哦。"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("再想想")),
          TextButton(
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).deleteAnchor(anchor.id);
              Navigator.pop(ctx);
            },
            child: const Text("确定", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildXPBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppTheme.accentWarmOrange, borderRadius: BorderRadius.circular(8)),
      child: Text("+${anchor.attributeDelta.getTotalPoints()}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}