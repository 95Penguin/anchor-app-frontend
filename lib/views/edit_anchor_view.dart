import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anchor_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class EditAnchorView extends StatefulWidget {
  final AnchorModel anchor;
  const EditAnchorView({Key? key, required this.anchor}) : super(key: key);

  @override
  State<EditAnchorView> createState() => _EditAnchorViewState();
}

class _EditAnchorViewState extends State<EditAnchorView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.anchor.title);
    _contentController = TextEditingController(text: widget.anchor.content);
    _locationController = TextEditingController(text: widget.anchor.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarm,
      appBar: AppBar(title: const Text('修改锚点')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.textBrown, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: '标题', hintText: '修改标题...'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: const TextStyle(color: AppTheme.textBrown, height: 1.5),
              decoration: const InputDecoration(labelText: '感悟内容', hintText: '重新组织下语言...'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: AppTheme.textBrown),
              decoration: const InputDecoration(
                labelText: '地点',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.accentWarmOrange),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AppProvider>(context, listen: false).updateAnchor(
                    widget.anchor.id,
                    _titleController.text,
                    _contentController.text,
                    _locationController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentWarmOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('同步修改', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}