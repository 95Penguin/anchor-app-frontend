// lib/views/drop_anchor_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../providers/app_provider.dart';
import '../models/anchor_model.dart';
import '../utils/app_theme.dart';
import '../services/image_helper.dart';

class DropAnchorView extends StatefulWidget {
  const DropAnchorView({Key? key}) : super(key: key);

  @override
  State<DropAnchorView> createState() => _DropAnchorViewState();
}

class _DropAnchorViewState extends State<DropAnchorView> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController(text: '位置');
  
  String _selectedAttr = '智'; 
  final List<String> _attrOptions = ['智', '力', '魅', '感', '毅'];
  
  List<String> _selectedImagePaths = [];
  String? _selectedMood;
  String? _selectedWeather;
  bool _isLoading = false;
  
  late AnimationController _fabController;
  
  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 5;

  final Map<String, String> _moodOptions = {
    '开心': '😊', '平静': '😌', '激动': '🤩',
    '难过': '😢', '焦虑': '😰', '疲惫': '😴',
  };

  final Map<String, String> _weatherOptions = {
    '晴天': '☀️', '多云': '⛅', '阴天': '☁️',
    '雨天': '🌧️', '雪天': '❄️', '雾天': '🌫️',
  };

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投掷锚点'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: AppTheme.textBrown, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                      decoration: InputDecoration(
                        hintText: "给这次记录起个名...",
                        hintStyle: TextStyle(color: AppTheme.textBrown.withOpacity(0.3)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  _buildQuickIcon(
                    icon: _selectedMood != null 
                        ? Text(_moodOptions[_selectedMood]!, style: const TextStyle(fontSize: 20))
                        : const Icon(Icons.mood_outlined, size: 20, color: AppTheme.textLightBrown),
                    onTap: _showMoodPicker,
                  ),
                  const SizedBox(width: 4),
                  _buildQuickIcon(
                    icon: _selectedWeather != null
                        ? Text(_weatherOptions[_selectedWeather]!, style: const TextStyle(fontSize: 20))
                        : const Icon(Icons.wb_sunny_outlined, size: 20, color: AppTheme.textLightBrown),
                    onTap: _showWeatherPicker,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedImagePaths.isNotEmpty) ...[
              _buildPhotoGrid(),
              const SizedBox(height: 16),
            ],
            
            if (_selectedImagePaths.length < maxImages)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.textBrown.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.textBrown.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, 
                        size: 36, 
                        color: AppTheme.textBrown.withOpacity(0.4)
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedImagePaths.isEmpty 
                            ? '添加照片(可选)'
                            : '继续添加 (${_selectedImagePaths.length}/$maxImages)',
                        style: TextStyle(
                          color: AppTheme.textBrown.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                style: const TextStyle(
                  color: AppTheme.textBrown, 
                  fontSize: 16, 
                  height: 1.6
                ),
                decoration: InputDecoration(
                  hintText: "此刻在想什么...",
                  hintStyle: TextStyle(color: AppTheme.textBrown.withOpacity(0.3)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 替换原来的 Row 区域（大约在第 280 行附近）
            Row(
              children: [
                // 属性选择器
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentWarmOrange.withOpacity(0.2),
                        AppTheme.accentWarmOrange.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.accentWarmOrange, size: 18),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: _selectedAttr,
                        underline: const SizedBox(),
                        dropdownColor: AppTheme.paperColor,
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentWarmOrange, size: 20),
                        style: const TextStyle(
                          color: AppTheme.textBrown,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        items: _attrOptions.map((attr) {
                          return DropdownMenuItem(
                            value: attr,
                            child: Text(attr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedAttr = value);
                          }
                        },
                      ),
                      const Text(
                        ' +5',
                        style: TextStyle(
                          color: AppTheme.accentWarmOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 地点输入框 - 优化版
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.textBrown.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded, 
                          color: AppTheme.accentWarmOrange, 
                          size: 18
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            style: const TextStyle(
                              color: AppTheme.textBrown, 
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '记录地点',
                              hintStyle: TextStyle(
                                color: AppTheme.textBrown.withOpacity(0.3), 
                                fontSize: 13
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _dropAnchor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentWarmOrange,
                  elevation: 4,
                  shadowColor: AppTheme.accentWarmOrange.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.anchor_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 12),
                          Text(
                            '投 掷 锚 点', 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 17, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 2
                            )
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImagePaths[index]),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImagePaths.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickIcon({required Widget icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: icon,
      ),
    );
  }

  void _showMoodPicker() {
    _triggerHapticFeedback();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('选择心情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBrown)),
                if (_selectedMood != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedMood = null);
                      Navigator.pop(ctx);
                    },
                    child: const Text('清除', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moodOptions.entries.map((entry) {
                bool isSelected = _selectedMood == entry.key;
                return GestureDetector(
                  onTap: () {
                    _triggerHapticFeedback();
                    setState(() => _selectedMood = entry.key);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentWarmOrange : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.accentWarmOrange : AppTheme.textBrown.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${entry.value} ${entry.key}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textBrown,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showWeatherPicker() {
    _triggerHapticFeedback();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('选择天气', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBrown)),
                if (_selectedWeather != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedWeather = null);
                      Navigator.pop(ctx);
                    },
                    child: const Text('清除', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _weatherOptions.entries.map((entry) {
                bool isSelected = _selectedWeather == entry.key;
                return GestureDetector(
                  onTap: () {
                    _triggerHapticFeedback();
                    setState(() => _selectedWeather = entry.key);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentWarmOrange : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.accentWarmOrange : AppTheme.textBrown.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${entry.value} ${entry.key}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textBrown,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    _triggerHapticFeedback();
    if (_selectedImagePaths.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('最多只能添加 $maxImages 张照片'),
          backgroundColor: AppTheme.textBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
            Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: Colors.grey[300], 
                borderRadius: BorderRadius.circular(2)
              )
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('拍照', style: TextStyle(color: AppTheme.textBrown)),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  await _processImage(photo.path);
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('从相册选择', style: TextStyle(color: AppTheme.textBrown)),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  await _processImage(image.path);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _isLoading = true);
    
    final compressedPath = await ImageHelper.compressAndSaveImage(imagePath);
    
    setState(() {
      _isLoading = false;
      if (compressedPath != null) {
        _selectedImagePaths.add(compressedPath);
      }
    });
  }

  Future<void> _dropAnchor() async {
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

    setState(() => _isLoading = true);
    _triggerHapticFeedback();

    final delta = AnchorModel.calculateAttributeDelta(_contentController.text, _selectedAttr);

    final anchor = AnchorModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      location: _locationController.text,
      companions: [],
      attributeDelta: delta,
      createdAt: DateTime.now(),
      imagePaths: _selectedImagePaths,
      mood: _selectedMood,
      weather: _selectedWeather,
    );

    await Provider.of<AppProvider>(context, listen: false).addAnchor(anchor);
    
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚓ 锚点已投掷!$_selectedAttr 属性 +5'), 
        backgroundColor: AppTheme.accentWarmOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      )
    );
    
    // 跳转到时间轴
    if (mounted) {
      DefaultTabController.of(context).animateTo(1);
    }
    
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedImagePaths.clear();
      _selectedMood = null;
      _selectedWeather = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _triggerHapticFeedback() {
    Vibrate.feedback(FeedbackType.light);
  }
}

// 在 drop_anchor_view.dart 文件末尾，修改 _triggerHapticFeedback 方法

void _triggerHapticFeedback() {
  try {
    // 只在移动端触发振动
    if (Platform.isAndroid || Platform.isIOS) {
      Vibrate.feedback(FeedbackType.light);
    }
  } catch (e) {
    // 忽略振动错误
    print('振动功能不可用: $e');
  }
}