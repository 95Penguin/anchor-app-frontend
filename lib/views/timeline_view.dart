// ==================== views/timeline_view.dart ====================
// 放在 lib/views/timeline_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anchors/providers/app_provider.dart';
import 'package:anchors/utils/app_theme.dart';
import 'package:anchors/widgets/anchor_card.dart';

class TimelineView extends StatelessWidget {
  const TimelineView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('时间轴', style: TextStyle(color: AppTheme.accentGreen)),
      ),
      body: provider.anchors.isEmpty
          ? Center(
              child: Text(
                '时间线空空如也\n开始记录你的故事吧',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.anchors.length,
              itemBuilder: (context, index) {
                final anchor = provider.anchors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnchorCard(anchor: anchor, showFull: true),
                );
              },
            ),
    );
  }
}
