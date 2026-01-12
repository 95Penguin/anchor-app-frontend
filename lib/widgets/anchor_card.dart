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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    anchor.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('MM-dd HH:mm').format(anchor.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              anchor.content,
              maxLines: showFull ? null : 2,
              overflow: showFull ? null : TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[300], height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppTheme.accentPurple),
                const SizedBox(width: 4),
                Text(
                  anchor.location,
                  style: const TextStyle(fontSize: 12, color: AppTheme.accentPurple),
                ),
                const Spacer(),
                // 展示前两个同伴标签
                ...anchor.companions.take(2).map((c) => Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(c, style: const TextStyle(fontSize: 10, color: AppTheme.accentPurple)),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}