// lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/anchor_model.dart';
import '../models/attribute_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    name: '旅行者',
    age: 20,
    attributes: AttributeModel(),
  );

  List<AnchorModel> _anchors = [];
  List<AnchorModel> _filteredAnchors = [];
  String _searchQuery = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _isLoading = true;

  UserModel get user => _user;
  List<AnchorModel> get anchors => _searchQuery.isEmpty && _filterStartDate == null
      ? List.unmodifiable(_anchors)
      : List.unmodifiable(_filteredAnchors);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  AppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    await _loadAnchors();
    await _checkInactivity();
    _isLoading = false;
    notifyListeners();
  }

  // 加载用户数据
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = await DatabaseHelper.instance.getUser();
    
    if (userData != null) {
      _user = UserModel(
        name: userData['name'],
        age: userData['age'],
        level: userData['level'],
        avatarPath: userData['avatarPath'] ?? '',
        bio: userData['bio'] ?? '在时光中投下锚点,对抗遗忘',
        attributes: AttributeModel(
          intelligence: userData['attrIntelligence'] ?? 0,
          strength: userData['attrStrength'] ?? 0,
          charisma: userData['attrCharisma'] ?? 0,
          perception: userData['attrPerception'] ?? 0,
          willpower: userData['attrWillpower'] ?? 0,
        ),
      );
    }
  }

  // 保存用户数据
  Future<void> _saveUserData() async {
    await DatabaseHelper.instance.saveUser({
      'id': 1,
      'name': _user.name,
      'age': _user.age,
      'level': _user.level,
      'avatarPath': _user.avatarPath,
      'bio': _user.bio,
      'attrIntelligence': _user.attributes.intelligence,
      'attrStrength': _user.attributes.strength,
      'attrCharisma': _user.attributes.charisma,
      'attrPerception': _user.attributes.perception,
      'attrWillpower': _user.attributes.willpower,
    });
  }

  // 加载锚点数据
  Future<void> _loadAnchors() async {
    _anchors = await DatabaseHelper.instance.getAnchors();
    _applyFilters();
  }

  // 增
  Future<void> addAnchor(AnchorModel anchor) async {
    _anchors.insert(0, anchor);
    _user.attributes.addAttributes(anchor.attributeDelta);
    _user.checkLevelUp();
    
    await DatabaseHelper.instance.insertAnchor(anchor);
    await _saveUserData();
    await _updateLastActiveDate();
    
    _applyFilters();
    notifyListeners();
  }

  // 删
  Future<void> deleteAnchor(String id) async {
    _anchors.removeWhere((a) => a.id == id);
    await DatabaseHelper.instance.deleteAnchor(id);
    _applyFilters();
    notifyListeners();
  }

  // 改
  Future<void> updateAnchorFull(AnchorModel updatedAnchor) async {
    int index = _anchors.indexWhere((a) => a.id == updatedAnchor.id);
    if (index != -1) {
      _anchors[index] = updatedAnchor;
      await DatabaseHelper.instance.updateAnchor(updatedAnchor);
      _applyFilters();
      notifyListeners();
    }
  }

  // 更新用户资料
  Future<void> updateUserProfile(String name, int age, String bio) async {
    _user.name = name;
    _user.age = age;
    _user.bio = bio;
    await _saveUserData();
    notifyListeners();
  }

  // 搜索功能
  Future<void> searchAnchors(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredAnchors = _anchors;
    } else {
      _filteredAnchors = await DatabaseHelper.instance.searchAnchors(query);
    }
    notifyListeners();
  }

  // 日期筛选
  void filterByDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty && _filterStartDate == null) {
      _filteredAnchors = _anchors;
      return;
    }

    _filteredAnchors = _anchors.where((anchor) {
      bool matchesSearch = _searchQuery.isEmpty ||
          anchor.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          anchor.content.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesDate = true;
      if (_filterStartDate != null && _filterEndDate != null) {
        matchesDate = anchor.createdAt.isAfter(_filterStartDate!) &&
            anchor.createdAt.isBefore(_filterEndDate!.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  // 清除筛选
  void clearFilters() {
    _searchQuery = '';
    _filterStartDate = null;
    _filterEndDate = null;
    _applyFilters();
    notifyListeners();
  }

  // 获取统计数据
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    final weekAnchors = _anchors.where((a) => a.createdAt.isAfter(weekAgo)).length;
    final monthAnchors = _anchors.where((a) => a.createdAt.isAfter(monthAgo)).length;

    // 统计最常去的地点
    Map<String, int> locationCount = {};
    for (var anchor in _anchors) {
      locationCount[anchor.location] = (locationCount[anchor.location] ?? 0) + 1;
    }
    final topLocation = locationCount.entries.isEmpty
        ? '未知'
        : locationCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // 统计最常见的心情
    Map<String, int> moodCount = {};
    for (var anchor in _anchors.where((a) => a.mood != null)) {
      moodCount[anchor.mood!] = (moodCount[anchor.mood!] ?? 0) + 1;
    }
    final topMood = moodCount.entries.isEmpty
        ? '未知'
        : moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'totalAnchors': _anchors.length,
      'weekAnchors': weekAnchors,
      'monthAnchors': monthAnchors,
      'topLocation': topLocation,
      'topMood': topMood,
      'currentStreak': _calculateStreak(),
    };
  }

  // 计算连续打卡天数
  int _calculateStreak() {
    if (_anchors.isEmpty) return 0;

    _anchors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    for (var anchor in _anchors) {
      final anchorDate = DateTime(
        anchor.createdAt.year,
        anchor.createdAt.month,
        anchor.createdAt.day,
      );
      final currentCheck = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      if (anchorDate == currentCheck || anchorDate == currentCheck.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = anchorDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // 检查不活跃提醒
  Future<void> _checkInactivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getString('lastActive');
    
    if (lastActive != null) {
      final lastDate = DateTime.parse(lastActive);
      final daysSince = DateTime.now().difference(lastDate).inDays;
      
      if (daysSince >= 3) {
        await NotificationService.instance.showInactivityReminder(daysSince);
      }
    }
  }

  // 更新最后活跃时间
  Future<void> _updateLastActiveDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastActive', DateTime.now().toIso8601String());
  }

  // 获取属性增长趋势数据
  List<Map<String, dynamic>> getAttributeTrendData() {
    List<Map<String, dynamic>> trendData = [];
    
    AttributeModel cumulative = AttributeModel();
    
    for (var anchor in _anchors.reversed) {
      cumulative.addAttributes(anchor.attributeDelta);
      trendData.add({
        'date': anchor.createdAt,
        'intelligence': cumulative.intelligence,
        'strength': cumulative.strength,
        'charisma': cumulative.charisma,
        'perception': cumulative.perception,
        'willpower': cumulative.willpower,
      });
    }
    
    return trendData;
  }

  // 导出数据
  String exportData() {
    // 简化版JSON导出
    return '''
{
  "user": {
    "name": "${_user.name}",
    "level": ${_user.level},
    "anchorsCount": ${_anchors.length}
  },
  "anchorsCount": ${_anchors.length},
  "totalExperience": ${_user.getExperience()}
}
''';
  }
}