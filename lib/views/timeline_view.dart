import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/anchor_card.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({Key? key}) : super(key: key);

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('时间轴'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: AppTheme.accentWarmOrange),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: provider.anchors.isEmpty
          ? _buildEmptyState()
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isGridView 
                  ? _buildWaterfallView(provider) // 切换为瀑布流
                  : _buildListView(provider),
            ),
    );
  }

  // 1. 列表模式 (保持不变)
  // 列表模式 (增加左侧连线效果)
  Widget _buildListView(AppProvider provider) {
    return ListView.builder(
      key: const ValueKey("list"),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: provider.anchors.length,
      itemBuilder: (context, index) {
        return IntrinsicHeight( // 【关键】：让左侧的线和右侧卡片高度同步
          child: Row(
            children: [
              // --- 左侧时间轴装饰线 ---
              SizedBox(
                width: 40, // 装饰区的宽度
                child: Column(
                  children: [
                    // 顶部的线 (第一个卡片不显示上半段)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index == 0 ? Colors.transparent : AppTheme.accentWarmOrange.withOpacity(0.3),
                      ),
                    ),
                    // 中间的发光圆点 (锚点象征)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.accentWarmOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentWarmOrange.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                    // 底部的线 (最后一个卡片不显示下半段)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index == provider.anchors.length - 1 
                            ? Colors.transparent 
                            : AppTheme.accentWarmOrange.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              // --- 右侧卡片内容 ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20), // 卡片之间的间距
                  child: AnchorCard(anchor: provider.anchors[index], showFull: true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. 【核心改进】：瀑布流网格模式
  Widget _buildWaterfallView(AppProvider provider) {
    // 将数据分为左列和右列
    List leftItems = [];
    List rightItems = [];
    for (int i = 0; i < provider.anchors.length; i++) {
      if (i % 2 == 0) leftItems.add(provider.anchors[i]);
      else rightItems.add(provider.anchors[i]);
    }

    return SingleChildScrollView(
      key: const ValueKey("grid"),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 关键：顶部对齐
        children: [
          // 左侧列
          Expanded(
            child: Column(
              children: leftItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnchorCard(anchor: item, showFull: false),
              )).toList(),
            ),
          ),
          const SizedBox(width: 16), // 中间间距
          // 右侧列
          Expanded(
            child: Column(
              children: rightItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnchorCard(anchor: item, showFull: false),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('时间线空空如也', style: TextStyle(color: Colors.grey)),
    );
  }
}