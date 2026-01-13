import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/anchor_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../views/edit_anchor_view.dart';

class AnchorCard extends StatelessWidget {
  final AnchorModel anchor;
  final bool showFull;

  const AnchorCard({Key? key, required this.anchor, this.showFull = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 单击：可以设为查看大图或详情（目前留空或进入编辑）
      onTap: () {}, 
      
      // 【核心修改】：长按弹出操作菜单
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
              _buildTopVisual(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题与时间行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        // 【修复】：重新显示时间
                        Text(
                          DateFormat('MM/dd HH:mm').format(anchor.createdAt),
                          style: TextStyle(
                            color: AppTheme.textLightBrown.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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

  // --- 弹出操作菜单 ---
  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 设置背景透明以实现自定义圆角
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWarm,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部的指示条
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            
            const Text("锚点操作", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textBrown)),
            const SizedBox(height: 10),
            
            // 修改选项
            ListTile(
              leading: CircleAvatar( // 【注意】：这里去掉了 const
                backgroundColor: Colors.blue.withOpacity(0.1), // 使用标准蓝色并加透明度
                child: const Icon(Icons.edit_rounded, color: Colors.blue),
              ),
              title: const Text("修改这段记录", style: TextStyle(color: AppTheme.textBrown)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditAnchorView(anchor: anchor)));
              },
            ),
            
            // 删除选项
            ListTile(
              leading: CircleAvatar( // 【注意】：这里去掉了 const
                backgroundColor: Colors.red.withOpacity(0.1), // 使用标准红色并加透明度
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

  Widget _buildTopVisual() {
    bool hasImage = anchor.imagePath != null;
    return Container(
      height: hasImage ? (showFull ? 120 : 80) : 4,
      width: double.infinity,
      color: AppTheme.accentWarmOrange.withOpacity(hasImage ? 0.05 : 0.8),
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