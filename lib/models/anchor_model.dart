// ==================== models/anchor_model.dart ====================
// 放在 lib/models/anchor_model.dart
import 'package:anchors/models/attribute_model.dart';

class AnchorModel {
  String id;
  String title;
  String content; // 随笔内容
  String location;
  List<String> companions; // 同伴标签
  AttributeModel attributeDelta; // 属性变化
  DateTime createdAt;
  String? imagePath;

  AnchorModel({
    required this.id,
    required this.title,
    required this.content,
    this.location = '未知地点',
    this.companions = const [],
    required this.attributeDelta,
    required this.createdAt,
    this.imagePath,
  });

  static AttributeModel calculateAttributeDelta(String content) {
    // 简单的关键词匹配算法，实际可以接入 NLP
    AttributeModel delta = AttributeModel();
    
    if (content.contains('学习') || content.contains('思考') || content.contains('理解')) {
      delta.intelligence = 5;
    }
    if (content.contains('运动') || content.contains('健身') || content.contains('锻炼')) {
      delta.strength = 5;
    }
    if (content.contains('社交') || content.contains('交流') || content.contains('朋友')) {
      delta.charisma = 5;
    }
    if (content.contains('感动') || content.contains('美') || content.contains('艺术')) {
      delta.perception = 5;
    }
    if (content.contains('坚持') || content.contains('努力') || content.contains('挑战')) {
      delta.willpower = 5;
    }

    // 保底增长：每次记录至少增加 3 点随机属性
    if (delta.getTotalPoints() == 0) {
      delta.willpower = 3;
    }

    return delta;
  }
}
