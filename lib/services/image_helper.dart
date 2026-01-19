// lib/services/image_helper.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static Future<String?> compressAndSaveImage(String imagePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = path.join(
        dir.path,
        'images',
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 确保目录存在
      await Directory(path.dirname(targetPath)).create(recursive: true);

      // Windows/Linux 平台：直接复制文件（压缩功能可能不完全支持）
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        print('桌面平台：直接复制图片文件');
        await File(imagePath).copy(targetPath);
        return targetPath;
      }

      // 移动端平台：压缩图片
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 85,
        minWidth: 1080,
        minHeight: 1080,
      );

      return result?.path ?? targetPath;
    } catch (e) {
      print('图片处理失败: $e');
      // 降级处理：直接复制原文件
      try {
        final dir = await getApplicationDocumentsDirectory();
        final targetPath = path.join(
          dir.path,
          'images',
          '${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await Directory(path.dirname(targetPath)).create(recursive: true);
        await File(imagePath).copy(targetPath);
        return targetPath;
      } catch (e2) {
        print('图片复制也失败: $e2');
        return null;
      }
    }
  }

  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('删除图片失败: $e');
    }
  }

  static Future<List<String>> compressMultipleImages(List<String> imagePaths) async {
    List<String> compressedPaths = [];
    for (String imagePath in imagePaths) {
      final compressed = await compressAndSaveImage(imagePath);
      if (compressed != null) {
        compressedPaths.add(compressed);
      }
    }
    return compressedPaths;
  }
}