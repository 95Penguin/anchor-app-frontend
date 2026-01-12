// ==================== models/attribute_model.dart ====================
// 放在 lib/models/attribute_model.dart
import 'package:flutter/material.dart';

class AttributeModel {
  int intelligence; // 智
  int strength;     // 力
  int charisma;     // 魅
  int perception;   // 感
  int willpower;    // 毅

  AttributeModel({
    this.intelligence = 0,
    this.strength = 0,
    this.charisma = 0,
    this.perception = 0,
    this.willpower = 0,
  });

  void addAttributes(AttributeModel delta) {
    intelligence += delta.intelligence;
    strength += delta.strength;
    charisma += delta.charisma;
    perception += delta.perception;
    willpower += delta.willpower;
  }

  int getTotalPoints() {
    return intelligence + strength + charisma + perception + willpower;
  }

  Map<String, int> toMap() {
    return {
      '智': intelligence,
      '力': strength,
      '魅': charisma,
      '感': perception,
      '毅': willpower,
    };
  }
}