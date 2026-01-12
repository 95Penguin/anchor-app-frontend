import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:anchors/models/attribute_model.dart';
import 'package:anchors/utils/app_theme.dart';

class RadarChartWidget extends StatelessWidget {
  final AttributeModel attributes;
  const RadarChartWidget({Key? key, required this.attributes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: AppTheme.accentGreen.withOpacity(0.3),
            borderColor: AppTheme.accentGreen,
            entryRadius: 3,
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
        radarBorderData: const BorderSide(color: Colors.grey, width: 1),
        getTitle: (index, angle) {
          // 对应 AttributeModel 中的五个维度
          final labels = ['智', '力', '魅', '感', '毅'];
          return RadarChartTitle(text: labels[index], angle: angle);
        },
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
      ),
    );
  }
}