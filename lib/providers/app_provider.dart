// ==================== providers/app_provider.dart ====================
// 放在 lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:anchors/models/user_model.dart';
import 'package:anchors/models/attribute_model.dart';
import 'package:anchors/models/anchor_model.dart';

class AppProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    name: '旅行者',
    age: 20,
    attributes: AttributeModel(
      intelligence: 10,
      strength: 10,
      charisma: 10,
      perception: 10,
      willpower: 10,
    ),
  );

  final List<AnchorModel> _anchors = [];

  UserModel get user => _user;
  List<AnchorModel> get anchors => List.unmodifiable(_anchors);

  List<AnchorModel> getRecentAnchors(int count) {
    if (_anchors.length <= count) return _anchors;
    return _anchors.sublist(0, count);
  }

  void addAnchor(AnchorModel anchor) {
    _anchors.insert(0, anchor);
    _user.attributes.addAttributes(anchor.attributeDelta);
    _user.checkLevelUp();
    notifyListeners();
  }

  void updateUserProfile(String name, int age, String bio) {
    _user.name = name;
    _user.age = age;
    _user.bio = bio;
    notifyListeners();
  }
}