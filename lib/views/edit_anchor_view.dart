import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  late List<String> _imagePaths;
  String? _selectedMood;
  String? _selectedWeather;
  
  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 5;

  final Map<String, String> _moodOptions = {
    '开心': '😊',
    '平静': '😌',
    '激动': '🤩',
    '难过': '😢',
    '焦虑': '😰',
    '疲惫': '😴',
  };

  final Map<String, String> _weatherOptions = {
    '晴天': '☀️',
    '多云': '⛅',
    '阴天': '☁️',
    '雨天': '🌧️',
    '雪天': '❄️',
    '雾天': '🌫️',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.anchor.title);
    _contentController = TextEditingController(text: widget.anchor.content);
    _locationController = TextEditingController(text: widget.anchor.location);
    _imagePaths = List.from(widget.anchor.imagePaths);
    _selectedMood = widget.anchor.mood;
    _selectedWeather = widget.anchor.weather;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarm,
      appBar: AppBar(
        title: const Text('修改锚点'),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              '保存',
              style: TextStyle(
                color: AppTheme.accentWarmOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题 + 心情天气
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
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '标题',
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

            // 照片展示和管理
            if (_imagePaths.isNotEmpty) ...[
              _buildPhotoGrid(),
              const SizedBox(height: 16),
            ],
            
            // 添加照片按钮
            if (_imagePaths.length < maxImages)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
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
                        size: 32, 
                        color: AppTheme.textBrown.withOpacity(0.4)
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _imagePaths.isEmpty 
                            ? '添加照片'
                            : '继续添加 (${_imagePaths.length}/$maxImages)',
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

            // 内容
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 10,
                style: const TextStyle(color: AppTheme.textBrown, height: 1.6),
                decoration: const InputDecoration(
                  hintText: '感悟内容',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 地点
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _locationController,
                style: const TextStyle(color: AppTheme.textBrown),
                decoration: const InputDecoration(
                  icon: Icon(Icons.location_on, color: AppTheme.accentWarmOrange),
                  hintText: '地点',
                  border: InputBorder.none,
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
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_imagePaths[index]),
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
                        _imagePaths.removeAt(index);
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
    if (_imagePaths.length >= maxImages) {
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
                  setState(() => _imagePaths.add(photo.path));
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
                  setState(() => _imagePaths.add(image.path));
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    // 注意：这里需要创建新的 anchor 对象来替换，因为 copyWith 不支持 imagePaths
    final updatedAnchor = AnchorModel(
      id: widget.anchor.id,
      title: _titleController.text,
      content: _contentController.text,
      location: _locationController.text,
      companions: widget.anchor.companions,
      attributeDelta: widget.anchor.attributeDelta,
      createdAt: widget.anchor.createdAt,
      imagePaths: _imagePaths,
      mood: _selectedMood,
      weather: _selectedWeather,
    );
    
    // 这里需要修改 app_provider 来支持完整替换
    Provider.of<AppProvider>(context, listen: false).updateAnchorFull(updatedAnchor);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('修改已保存'),
        backgroundColor: AppTheme.accentWarmOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}