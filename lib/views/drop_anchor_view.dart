import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/anchor_model.dart';
import '../utils/app_theme.dart';

class DropAnchorView extends StatefulWidget {
  const DropAnchorView({Key? key}) : super(key: key);

  @override
  State<DropAnchorView> createState() => _DropAnchorViewState();
}

class _DropAnchorViewState extends State<DropAnchorView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController(text: '位置');
  
  String _selectedAttr = '智'; 
  final List<String> _attrOptions = ['智', '力', '魅', '感', '毅'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投掷锚点'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // 【关键】：设置与时间轴完全一致的左右边距
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          // 【关键】：强制所有子组件横向撑满
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 标题
            _buildLabel("标题"),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.textBrown, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "给这次记录起个名...",
              ),
            ),
            const SizedBox(height: 24),

            // 2. 感悟内容
            _buildLabel("感悟内容"),
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: const TextStyle(color: AppTheme.textBrown, fontSize: 16, height: 1.5),
              decoration: const InputDecoration(
                hintText: "此刻在想什么...",
              ),
            ),
            const SizedBox(height: 24),

            // 3. 属性选择器
            _buildLabel("本次成长的维度"),
            const SizedBox(height: 8),
            // 将选择器包裹在 Wrap 或 Row 中，使其不再受 stretch 强行拉伸
            Align(
              alignment: Alignment.centerLeft,
              child: _buildAttributeSelector(),
            ),
            const SizedBox(height: 24),

            // 4. 地点
            _buildLabel("地点"),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: AppTheme.textBrown),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_rounded, color: AppTheme.accentWarmOrange, size: 20),
              ),
            ),
            const SizedBox(height: 40),

            // 5. 投掷按钮
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _dropAnchor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentWarmOrange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.anchor_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      '投 掷 锚 点', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 2
                      )
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // 底部留空，防止被遮挡
          ],
        ),
      ),
    );
  }

  // 构建标签
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.textBrown.withOpacity(0.6), 
          fontSize: 14, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  // 紧凑型选择器
  Widget _buildAttributeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.textBrown.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _attrOptions.map((attr) {
          bool isSelected = _selectedAttr == attr;
          return GestureDetector(
            onTap: () => setState(() => _selectedAttr = attr),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentWarmOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                attr,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _dropAnchor() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请填写标题和内容哦"), 
          backgroundColor: AppTheme.textBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final delta = AnchorModel.calculateAttributeDelta(_contentController.text, _selectedAttr);

    final anchor = AnchorModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      location: _locationController.text,
      companions: [],
      attributeDelta: delta,
      createdAt: DateTime.now(),
    );

    Provider.of<AppProvider>(context, listen: false).addAnchor(anchor);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚓ 锚点已投掷！$_selectedAttr 属性 +5'), 
        backgroundColor: AppTheme.accentWarmOrange,
        behavior: SnackBarBehavior.floating,
      )
    );
    
    // 清空并收起键盘
    _titleController.clear();
    _contentController.clear();
    FocusScope.of(context).unfocus();
  }
}