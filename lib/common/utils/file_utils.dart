import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;


/*
  // 设置要删除的目录路径和通配符模式
  String directoryPath = '/path/to/your/directory';  // 替换为实际路径
  String pattern = r'.*\.txt$';  // 匹配所有以 .txt 结尾的文件

  deleteFilesByPattern(directoryPath, pattern);
 */

void deleteFilesByPattern(String directoryPath, String pattern) async {
  try {
    final directory = Directory(directoryPath);

    // 获取目录中的所有文件
    var files = directory.listSync(); // listSync() 获取所有文件和目录的列表

    // 使用正则表达式过滤文件
    RegExp regExp = RegExp(pattern); // 使用传入的模式作为正则表达式
    List<FileSystemEntity> matchedFiles = [];

    // 遍历所有文件，筛选符合条件的文件
    for (var file in files) {
      if (file is File && regExp.hasMatch(file.uri.pathSegments.last)) {
        matchedFiles.add(file);
      }
    }

    // 删除匹配的文件
    for (var file in matchedFiles) {
      await file.delete();
      print('已删除文件: ${file.path}');
    }
  } catch (e) {
    print('删除文件时发生错误: $e');
  }
}


bool isLocalFilePath(String path) {
  return path.startsWith('/') || path.startsWith('file://');
}


// 创建多级目录，如果目录已存在会自动跳过
Future<Directory> createNestedDirectory(String fullPath) async {
  final directory = Directory(fullPath);
  if (!(await directory.exists())) {
    await directory.create(recursive: true);
  }
  return directory;
}


Future<File?> singleCompressFile(File file, String targetPath, {int quality = 80}) async {
  try {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: quality
    );

    print(file.lengthSync());
    if(result == null) return null;
    File fileret = File(result.path);
    return fileret;

  }catch (e) {
    print("Error during compression: $e");
    return null;
  }

}

String getFileName(String filePath)
{
// 直接获取扩展名
return p.basename(filePath);
}

//
String formatBytes(int bytes, [int decimals = 2]) {

  if (bytes < 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }

  return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
}
