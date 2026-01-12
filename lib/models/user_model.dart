// ==================== models/user_model.dart ====================
// 放在 lib/models/user_model.dart
import 'package:anchors/models/attribute_model.dart';

class UserModel {
  String name;
  int age;
  int level;
  String avatarPath;
  String bio; // 座右铭
  AttributeModel attributes;

  UserModel({
    required this.name,
    required this.age,
    this.level = 1,
    this.avatarPath = '',
    this.bio = '在时光中投下锚点,对抗遗忘',
    required this.attributes,
  });

  int getExperience() {
    return attributes.getTotalPoints();
  }

  int getExpForNextLevel() {
    return level * 100; // 每级需要 level * 100 经验
  }

  double getExpProgress() {
    int currentExp = getExperience() % getExpForNextLevel();
    return currentExp / getExpForNextLevel();
  }

  void checkLevelUp() {
    while (getExperience() >= getExpForNextLevel()) {
      level++;
    }
  }
}