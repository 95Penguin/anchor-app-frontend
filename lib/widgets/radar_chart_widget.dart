import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/attribute_model.dart';
import '../utils/app_theme.dart';

class RadarChartWidget extends StatelessWidget {
  final AttributeModel attributes;
  final bool isMini;

  const RadarChartWidget({Key? key, required this.attributes, this.isMini = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        // 【核心修复点】：文字样式要在这里统一设置，而不是在 getTitle 里
        titleTextStyle: isMini 
            ? const TextStyle(color: Colors.transparent) // 微缩模式文字透明
            : const TextStyle(color: AppTheme.textBrown, fontSize: 12, fontWeight: FontWeight.bold),
        
        dataSets: [
          RadarDataSet(
            fillColor: AppTheme.accentWarmOrange.withOpacity(0.4),
            borderColor: AppTheme.accentWarmOrange,
            entryRadius: isMini ? 1 : 3,
            dataEntries: [
              RadarEntry(value: attributes.intelligence.toDouble()),
              RadarEntry(value: attributes.strength.toDouble()),
              RadarEntry(value: attributes.charisma.toDouble()),
              RadarEntry(value: attributes.perception.toDouble()),
              RadarEntry(value: attributes.willpower.toDouble()),
            ],
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: BorderSide(color: AppTheme.textBrown.withOpacity(0.1)),
        
        // 修改后的 getTitle，只负责返回文字和角度
        getTitle: (index, angle) {
          if (isMini) return const RadarChartTitle(text: '');
          final labels = ['智', '力', '魅', '感', '毅'];
          return RadarChartTitle(
            text: labels[index], 
            angle: angle,
          );
        },
        
        tickCount: 1, 
        ticksTextStyle: const TextStyle(color: Colors.transparent), 
        gridBorderData: BorderSide(
          color: AppTheme.textBrown.withOpacity(isMini ? 0.05 : 0.1)
        ),
      ),
    );
  }
}