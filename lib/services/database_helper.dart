// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/anchor_model.dart';
import '../models/attribute_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('anchors.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE anchors(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        location TEXT NOT NULL,
        companions TEXT,
        attrIntelligence INTEGER,
        attrStrength INTEGER,
        attrCharisma INTEGER,
        attrPerception INTEGER,
        attrWillpower INTEGER,
        createdAt TEXT NOT NULL,
        imagePaths TEXT,
        mood TEXT,
        weather TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        level INTEGER NOT NULL,
        avatarPath TEXT,
        bio TEXT,
        attrIntelligence INTEGER,
        attrStrength INTEGER,
        attrCharisma INTEGER,
        attrPerception INTEGER,
        attrWillpower INTEGER
      )
    ''');
  }

  // 保存锚点
  Future<void> insertAnchor(AnchorModel anchor) async {
    final db = await database;
    await db.insert(
      'anchors',
      {
        'id': anchor.id,
        'title': anchor.title,
        'content': anchor.content,
        'location': anchor.location,
        'companions': anchor.companions.join(','),
        'attrIntelligence': anchor.attributeDelta.intelligence,
        'attrStrength': anchor.attributeDelta.strength,
        'attrCharisma': anchor.attributeDelta.charisma,
        'attrPerception': anchor.attributeDelta.perception,
        'attrWillpower': anchor.attributeDelta.willpower,
        'createdAt': anchor.createdAt.toIso8601String(),
        'imagePaths': anchor.imagePaths.join('|'),
        'mood': anchor.mood,
        'weather': anchor.weather,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 读取所有锚点
  Future<List<AnchorModel>> getAnchors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'anchors',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return AnchorModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        location: maps[i]['location'],
        companions: maps[i]['companions'].toString().split(',').where((s) => s.isNotEmpty).toList(),
        attributeDelta: AttributeModel(
          intelligence: maps[i]['attrIntelligence'],
          strength: maps[i]['attrStrength'],
          charisma: maps[i]['attrCharisma'],
          perception: maps[i]['attrPerception'],
          willpower: maps[i]['attrWillpower'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt']),
        imagePaths: maps[i]['imagePaths'].toString().split('|').where((s) => s.isNotEmpty).toList(),
        mood: maps[i]['mood'],
        weather: maps[i]['weather'],
      );
    });
  }

  // 更新锚点
  Future<void> updateAnchor(AnchorModel anchor) async {
    final db = await database;
    await db.update(
      'anchors',
      {
        'title': anchor.title,
        'content': anchor.content,
        'location': anchor.location,
        'companions': anchor.companions.join(','),
        'imagePaths': anchor.imagePaths.join('|'),
        'mood': anchor.mood,
        'weather': anchor.weather,
      },
      where: 'id = ?',
      whereArgs: [anchor.id],
    );
  }

  // 删除锚点
  Future<void> deleteAnchor(String id) async {
    final db = await database;
    await db.delete(
      'anchors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 搜索锚点
  Future<List<AnchorModel>> searchAnchors(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'anchors',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return AnchorModel(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        location: maps[i]['location'],
        companions: maps[i]['companions'].toString().split(',').where((s) => s.isNotEmpty).toList(),
        attributeDelta: AttributeModel(
          intelligence: maps[i]['attrIntelligence'],
          strength: maps[i]['attrStrength'],
          charisma: maps[i]['attrCharisma'],
          perception: maps[i]['attrPerception'],
          willpower: maps[i]['attrWillpower'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt']),
        imagePaths: maps[i]['imagePaths'].toString().split('|').where((s) => s.isNotEmpty).toList(),
        mood: maps[i]['mood'],
        weather: maps[i]['weather'],
      );
    });
  }

  // 保存用户信息
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'user',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 读取用户信息
  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user', limit: 1);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}