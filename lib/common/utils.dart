
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';
export   'utils/file_utils.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class Utils {

  ///@nodoc
  ///
  static String generateUniqueString() {
    var random = Random();
    var uniqueString = '';
    var characters =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

    while (uniqueString.length < 32) {
      var randomIndex = random.nextInt(characters.length);
      var randomChar = characters[randomIndex];
      uniqueString += randomChar;
    }

    return uniqueString;
  }

  static Map<String, dynamic> formatJson(Map? jsonSrc) {
    if (jsonSrc != null) {
      return Map<String, dynamic>.from(jsonSrc);
    }
    return Map<String, dynamic>.from({});
  }

  static int StringToInt(String? str)
  {
    if(str == null) return 0;
    int number = 0;
    try {
      number = int.parse(str);  // 尝试将字符串转换为 int
    } catch (e) {
      print('StringToInt Error: $e');  // 捕获并处理异常
    }
    return number;
  }

  static String shortenString(String input, int maxLength, String connector, String emptyTip) {
    if(input.isEmpty) return emptyTip;
    if (input.length <= maxLength) {
      return input; // 如果字符串长度小于或等于最大长度，直接返回原字符串
    }

    int connectorLength = connector.length;
    if (maxLength <= connectorLength) {
      return input.substring(0, maxLength); // 如果最大长度不足以添加连接符，直接截取前 maxLength 部分
    }

    // 计算前后保留的部分长度
    int partLength = (maxLength - connectorLength) ~/ 2;

    // 构造缩短后的字符串
    return input.substring(0, partLength) +
        connector +
        input.substring(input.length - partLength);


  }

  static bool isEmptyStr(String? str)
  {
      if(str == null || str.isEmpty) return true;
      return false;
  }


  static String getFileExt(String filePath)
  {
    // 直接获取扩展名
    return path.extension(filePath);
  }


}



class AndroidUtils {
  static const platform = MethodChannel("com.liyin.freeman/androidInvoke");

  static Future<void> minimizeApp() async {
    try {
      await platform.invokeMethod("minimizeApp");
    } on PlatformException catch (e) {
      print("Failed to minimize app: ${e.message}");
    }
  }
}


