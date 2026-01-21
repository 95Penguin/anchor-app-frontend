// lib/widgets/anchor_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/anchor_model.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../views/edit_anchor_view.dart';
import '../views/anchor_detail_view.dart';
import '../views/lazy_image.dart';

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
      case AppThemeMode.custom:
        return themeProvider.customColor;
      default:
        return const Color(0xFFFF8A65);
    }
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = _getAccentColor(themeProvider);
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = textColor.withOpacity(0.6);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnchorDetailView(anchor: anchor),
          ),
        );
      },
      onLongPress: () => _showActionMenu(context, accentColor, cardColor, textColor),
      
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.08),
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
              // 照片展示区域
              _buildPhotoSection(accentColor, textColor),
              
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
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                          color: subtitleColor,
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
                        color: subtitleColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 地点和经验值
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: accentColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            anchor.location,
                            style: TextStyle(fontSize: 10, color: subtitleColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildXPBadge(accentColor),
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

  Widget _buildPhotoSection(Color accentColor, Color textColor) {
    if (anchor.imagePaths.isEmpty) {
      return Container(
        height: 4,
        width: double.infinity,
        color: accentColor.withOpacity(0.8),
      );
    }

    if (!showFull) {
      return SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 使用懒加载图片
            LazyImage(
              imagePath: anchor.imagePaths.first,
              fit: BoxFit.cover,
              placeholder: Container(
                color: accentColor.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
              errorWidget: Container(
                color: accentColor.withOpacity(0.1),
                child: Center(
                  child: Icon(Icons.broken_image, color: textColor.withOpacity(0.4), size: 40),
                ),
              ),
            ),
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

    return SizedBox(
      height: 200,
      child: anchor.imagePaths.length == 1
          ? LazyImage(
              imagePath: anchor.imagePaths.first,
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
                  child: LazyImage(
                    imagePath: anchor.imagePaths[index],
                    fit: BoxFit.cover,
                    width: 200,
                  ),
                );
              },
            ),
    );
  }

  void _showActionMenu(BuildContext context, Color accentColor, Color backgroundColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(2)
              )
            ),
            const SizedBox(height: 20),
            
            Text("锚点操作", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            const SizedBox(height: 10),
            
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.edit_rounded, color: Colors.blue),
              ),
              title: Text("修改这段记录", style: TextStyle(color: textColor)),
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
                _confirmDelete(context, backgroundColor, textColor);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Color backgroundColor, Color textColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("确定抹除？", style: TextStyle(color: textColor)),
        content: Text("一旦撤回，对应的属性成长也会受到影响哦。", style: TextStyle(color: textColor)),
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

  Widget _buildXPBadge(Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        "+${anchor.attributeDelta.getTotalPoints()}", 
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }
}