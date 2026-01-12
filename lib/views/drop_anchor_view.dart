// ==================== views/drop_anchor_view.dart ====================
// 放在 lib/views/drop_anchor_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anchors/providers/app_provider.dart';
import 'package:anchors/models/anchor_model.dart'; // 必须引用这个，系统才认识 AnchorModel
import 'package:anchors/utils/app_theme.dart';

class DropAnchorView extends StatefulWidget {
  const DropAnchorView({Key? key}) : super(key: key);

  @override
  State<DropAnchorView> createState() => _DropAnchorViewState();
}

class _DropAnchorViewState extends State<DropAnchorView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController(text: '当前位置');
  final List<String> _companions = [];
  final _companionInputController = TextEditingController();

  void _addCompanion() {
    if (_companionInputController.text.trim().isNotEmpty) {
      setState(() {
        _companions.add(_companionInputController.text.trim());
        _companionInputController.clear();
      });
    }
  }

  void _dropAnchor() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写标题和内容'), backgroundColor: Colors.red),
      );
      return;
    }

    final attributeDelta = AnchorModel.calculateAttributeDelta(_contentController.text);
    final anchor = AnchorModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      location: _locationController.text.trim(),
      companions: List.from(_companions),
      attributeDelta: attributeDelta,
      createdAt: DateTime.now(),
    );

    Provider.of<AppProvider>(context, listen: false).addAnchor(anchor);

    // TODO: 添加震动反馈 - HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('锚点已投掷! +${attributeDelta.getTotalPoints()} 经验'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );

    // 清空表单
    _titleController.clear();
    _contentController.clear();
    _locationController.text = '当前位置';
    setState(() => _companions.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投掷锚点', style: TextStyle(color: AppTheme.accentGreen)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '标题',
                labelStyle: const TextStyle(color: AppTheme.accentGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.accentGreen),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '记录你的感悟',
                labelStyle: const TextStyle(color: AppTheme.accentGreen),
                hintText: '今天发生了什么值得记录的事...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.accentGreen),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '地点',
                labelStyle: const TextStyle(color: AppTheme.accentPurple),
                prefixIcon: const Icon(Icons.location_on, color: AppTheme.accentPurple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('同伴', style: TextStyle(color: AppTheme.accentPurple, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _companionInputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '添加同伴标签',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCompanion,
                  icon: const Icon(Icons.add_circle, color: AppTheme.accentGreen, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _companions
                  .map((c) => Chip(
                        label: Text(c),
                        backgroundColor: AppTheme.accentPurple.withOpacity(0.2),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => _companions.remove(c)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // 照片占位符
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('添加照片 (占位)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _dropAnchor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  '⚓ 投掷锚点',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _companionInputController.dispose();
    super.dispose();
  }
}
