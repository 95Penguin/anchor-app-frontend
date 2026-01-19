// lib/views/timeline_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSearchBar = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? _buildSearchField(provider) : const Text('时间轴'),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: AppTheme.accentWarmOrange),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear();
                  provider.clearFilters();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.accentWarmOrange),
            onPressed: () => _showFilterDialog(context, provider),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: AppTheme.accentWarmOrange),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.anchors.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    // 刷新数据
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isGridView 
                        ? _buildWaterfallView(provider)
                        : _buildListView(provider),
                  ),
                ),
    );
  }

  Widget _buildSearchField(AppProvider provider) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: AppTheme.textBrown),
      decoration: InputDecoration(
        hintText: '搜索标题或内容...',
        hintStyle: TextStyle(color: AppTheme.textBrown.withOpacity(0.5)),
        border: InputBorder.none,
      ),
      onChanged: (value) => provider.searchAnchors(value),
    );
  }

  void _showFilterDialog(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWarm,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '筛选选项',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBrown,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppTheme.accentWarmOrange),
              title: const Text('按日期筛选'),
              onTap: () async {
                Navigator.pop(ctx);
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  provider.filterByDateRange(picked.start, picked.end);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.red),
              title: const Text('清除所有筛选'),
              onTap: () {
                provider.clearFilters();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// lib/views/timeline_view.dart
// 找到 _buildListView 方法（大约在第 120 行），替换为以下代码：

Widget _buildListView(AppProvider provider) {
  final groupedAnchors = _groupAnchorsByDate(provider.anchors);
  
  return ListView.builder(
    key: const ValueKey("list"),
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    itemCount: groupedAnchors.length,
    itemBuilder: (context, index) {
      final entry = groupedAnchors.entries.elementAt(index);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标题
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentWarmOrange,
              ),
            ),
          ),
          // 该日期的所有锚点
          ...entry.value.map((anchor) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间轴指示器
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      // 上方连接线
                      Container(
                        width: 2,
                        height: entry.value.indexOf(anchor) == 0 ? 0 : 30,
                        color: AppTheme.accentWarmOrange.withOpacity(0.3),
                      ),
                      // 圆点
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
                      // 下方连接线
                      Container(
                        width: 2,
                        height: entry.value.indexOf(anchor) == entry.value.length - 1 ? 0 : 30,
                        color: AppTheme.accentWarmOrange.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 锚点卡片 - 关键：showFull 设为 false 才显示内容
                Expanded(
                  child: AnchorCard(anchor: anchor, showFull: false),
                ),
              ],
            ),
          )),
        ],
      );
    },
  );
}

  Map<String, List> _groupAnchorsByDate(List anchors) {
    Map<String, List> grouped = {};
    final now = DateTime.now();
    
    for (var anchor in anchors) {
      String dateKey;
      final anchorDate = DateTime(
        anchor.createdAt.year,
        anchor.createdAt.month,
        anchor.createdAt.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      if (anchorDate == today) {
        dateKey = '今天';
      } else if (anchorDate == yesterday) {
        dateKey = '昨天';
      } else if (now.difference(anchorDate).inDays < 7) {
        dateKey = '本周';
      } else {
        dateKey = DateFormat('yyyy年MM月').format(anchor.createdAt);
      }
      
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(anchor);
    }
    
    return grouped;
  }

  Widget _buildWaterfallView(AppProvider provider) {
    List leftItems = [];
    List rightItems = [];
    for (int i = 0; i < provider.anchors.length; i++) {
      if (i % 2 == 0) {
        leftItems.add(provider.anchors[i]);
      } else {
        rightItems.add(provider.anchors[i]);
      }
    }

    return SingleChildScrollView(
      key: const ValueKey("grid"),
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: leftItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnchorCard(anchor: item, showFull: false),
              )).toList(),
            ),
          ),
          const SizedBox(width: 16),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.anchor,
            size: 80,
            color: AppTheme.textBrown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '时间线空空如也',
            style: TextStyle(
              color: AppTheme.textLightBrown,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '快去投下第一个锚点吧!',
            style: TextStyle(
              color: AppTheme.textLightBrown,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}