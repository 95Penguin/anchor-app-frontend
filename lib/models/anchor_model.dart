import 'attribute_model.dart';

class AnchorModel {
  String id;
  String title;
  String content;
  String location;
  List<String> companions;
  AttributeModel attributeDelta; // 本次记录带来的属性增量
  DateTime createdAt;
  String? imagePath;

  AnchorModel({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.companions,
    required this.attributeDelta,
    required this.createdAt,
    this.imagePath,
  });

  // 【核心修改】：根据用户选择的属性名（智/力/魅/感/毅）来生成增量
  static AttributeModel calculateAttributeDelta(String content, String selectedType) {
    AttributeModel delta = AttributeModel(
      intelligence: 0, strength: 0, charisma: 0, perception: 0, willpower: 0
    );

    // 主属性固定加 5 点
    switch (selectedType) {
      case '智': delta.intelligence = 5; break;
      case '力': delta.strength = 5; break;
      case '魅': delta.charisma = 5; break;
      case '感': delta.perception = 5; break;
      case '毅': delta.willpower = 5; break;
    }

    // 只要记录了，保底全属性增加 1 点（成长的见证）
    // 或者你可以根据文本长度加一点点经验
    return delta;
  }

  AnchorModel copyWith({
    String? title,
    String? content,
    String? location,
    List<String>? companions,
  }) {
    return AnchorModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      companions: companions ?? this.companions,
      attributeDelta: attributeDelta,
      createdAt: createdAt,
      imagePath: imagePath,
    );
  }
}