import 'attribute_model.dart';

class AnchorModel {
  String id;
  String title;
  String content;
  String location;
  List<String> companions;
  AttributeModel attributeDelta;
  DateTime createdAt;
  List<String> imagePaths; // 【修改】改为列表支持多张照片
  String? mood;
  String? weather;

  AnchorModel({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.companions,
    required this.attributeDelta,
    required this.createdAt,
    List<String>? imagePaths, // 【修改】可选的图片列表
    this.mood,
    this.weather,
  }) : imagePaths = imagePaths ?? [];

  // 兼容旧版本的 imagePath 属性
  String? get imagePath => imagePaths.isNotEmpty ? imagePaths.first : null;

  static AttributeModel calculateAttributeDelta(String content, String selectedType) {
    AttributeModel delta = AttributeModel(
      intelligence: 0, strength: 0, charisma: 0, perception: 0, willpower: 0
    );

    switch (selectedType) {
      case '智': delta.intelligence = 5; break;
      case '力': delta.strength = 5; break;
      case '魅': delta.charisma = 5; break;
      case '感': delta.perception = 5; break;
      case '毅': delta.willpower = 5; break;
    }

    return delta;
  }

  AnchorModel copyWith({
    String? title,
    String? content,
    String? location,
    List<String>? companions,
    String? mood,
    String? weather,
  }) {
    return AnchorModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      companions: companions ?? this.companions,
      attributeDelta: attributeDelta,
      createdAt: createdAt,
      imagePaths: imagePaths,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
    );
  }
}