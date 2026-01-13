import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/anchor_model.dart';
import '../models/attribute_model.dart';

class AppProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    name: '旅行者',
    age: 20,
    attributes: AttributeModel(),
  );

  final List<AnchorModel> _anchors = [];

  UserModel get user => _user;
  List<AnchorModel> get anchors => List.unmodifiable(_anchors);

  // 增
  void addAnchor(AnchorModel anchor) {
    _anchors.insert(0, anchor);
    _user.attributes.addAttributes(anchor.attributeDelta);
    _user.checkLevelUp();
    notifyListeners();
  }

  // 【删】：按ID删除
  void deleteAnchor(String id) {
    _anchors.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // 【改】：按ID更新内容
  void updateAnchor(String id, String title, String content, String location) {
    int index = _anchors.indexWhere((a) => a.id == id);
    if (index != -1) {
      _anchors[index] = _anchors[index].copyWith(
        title: title,
        content: content,
        location: location,
      );
      notifyListeners();
    }
  }

  void updateUserProfile(String name, int age, String bio) {
    _user.name = name;
    _user.age = age;
    _user.bio = bio;
    notifyListeners();
  }
}