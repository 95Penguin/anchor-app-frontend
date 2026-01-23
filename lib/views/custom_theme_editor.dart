// lib/views/custom_theme_editor.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomThemeEditor extends StatefulWidget {
  const CustomThemeEditor({Key? key}) : super(key: key);

  @override
  State<CustomThemeEditor> createState() => _CustomThemeEditorState();
}

class _CustomThemeEditorState extends State<CustomThemeEditor> {
  Color _selectedColor = const Color(0xFFFF8A65);

  // 预设主题色
  final List<Map<String, dynamic>> _presetThemes = [
    {'name': '暖橙色', 'color': const Color(0xFFFF8A65)},
    {'name': '海洋蓝', 'color': const Color(0xFF0097A7)},
    {'name': '森林绿', 'color': const Color(0xFF4CAF50)},
    {'name': '樱花粉', 'color': const Color(0xFFEC407A)},
    {'name': '深海蓝', 'color': const Color(0xFF1565C0)},
    {'name': '极光紫', 'color': const Color(0xFF7E57C2)},
    {'name': '日落橙', 'color': const Color(0xFFFF6F00)},
    {'name': '薄荷绿', 'color': const Color(0xFF26A69A)},
    {'name': '玫瑰红', 'color': const Color(0xFFD32F2F)},
    {'name': '琥珀黄', 'color': const Color(0xFFFFB300)},
    {'name': '靛青蓝', 'color': const Color(0xFF303F9F)},
    {'name': '湖水青', 'color': const Color(0xFF00ACC1)},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义主题'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // 保存自定义主题
              themeProvider.setCustomColor(_selectedColor);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('主题已保存'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 预览卡片
          _buildPreviewCard(),
          const SizedBox(height: 24),

          // 预设主题
          const Text(
            '预设主题',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85, // 【修改】从默认的 1.0 改为 0.85，增加高度
            ),
            itemCount: _presetThemes.length,
            itemBuilder: (context, index) {
              final theme = _presetThemes[index];
              final isSelected = _selectedColor.value == (theme['color'] as Color).value;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = theme['color'] as Color;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 【添加】限制 Column 大小
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme['color'] as Color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: (theme['color'] as Color).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Flexible( // 【修改】用 Flexible 包裹文本，允许自适应
                      child: Text(
                        theme['name'] as String,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 1, // 【添加】限制最多1行
                        overflow: TextOverflow.ellipsis, // 【添加】溢出显示省略号
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // 色相调节
          const Text(
            '色相调节',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHueSlider(),
          const SizedBox(height: 24),

          // 饱和度调节
          const Text(
            '饱和度',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSaturationSlider(),
          const SizedBox(height: 24),

          // 亮度调节
          const Text(
            '亮度',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildLightnessSlider(),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _selectedColor.withOpacity(0.2),
              _selectedColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              '主题预览',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.anchor, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    '锚点已投掷',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '+5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHueSlider() {
    final hslColor = HSLColor.fromColor(_selectedColor);
    
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: List.generate(
                360,
                (index) => HSLColor.fromAHSL(
                  1.0,
                  index.toDouble(),
                  hslColor.saturation,
                  hslColor.lightness,
                ).toColor(),
              ),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Slider(
          value: hslColor.hue,
          min: 0,
          max: 360,
          activeColor: _selectedColor,
          onChanged: (value) {
            setState(() {
              _selectedColor = HSLColor.fromAHSL(
                1.0,
                value,
                hslColor.saturation,
                hslColor.lightness,
              ).toColor();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSaturationSlider() {
    final hslColor = HSLColor.fromColor(_selectedColor);
    
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HSLColor.fromAHSL(1.0, hslColor.hue, 0.0, hslColor.lightness).toColor(),
                HSLColor.fromAHSL(1.0, hslColor.hue, 1.0, hslColor.lightness).toColor(),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Slider(
          value: hslColor.saturation,
          min: 0,
          max: 1,
          activeColor: _selectedColor,
          onChanged: (value) {
            setState(() {
              _selectedColor = HSLColor.fromAHSL(
                1.0,
                hslColor.hue,
                value,
                hslColor.lightness,
              ).toColor();
            });
          },
        ),
      ],
    );
  }

  Widget _buildLightnessSlider() {
    final hslColor = HSLColor.fromColor(_selectedColor);
    
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HSLColor.fromAHSL(1.0, hslColor.hue, hslColor.saturation, 0.0).toColor(),
                HSLColor.fromAHSL(1.0, hslColor.hue, hslColor.saturation, 0.5).toColor(),
                HSLColor.fromAHSL(1.0, hslColor.hue, hslColor.saturation, 1.0).toColor(),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Slider(
          value: hslColor.lightness,
          min: 0,
          max: 1,
          activeColor: _selectedColor,
          onChanged: (value) {
            setState(() {
              _selectedColor = HSLColor.fromAHSL(
                1.0,
                hslColor.hue,
                hslColor.saturation,
                value,
              ).toColor();
            });
          },
        ),
      ],
    );
  }
}