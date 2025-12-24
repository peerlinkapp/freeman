import 'dart:ffi';
import 'dart:convert';



extension CharArrayToString on Array<Char> {
  String toDartString({int maxLength = 10240}) {
    // 创建一个 Dart 字符串缓冲区

    List<int> utf8Bytes = [];

    // 遍历数组，读取每个字符
    for (int i = 0; i < maxLength; i++) {
      final charCode = this[i];
      if (charCode == 0) break;
      utf8Bytes.add(charCode);
    }

    // 尝试解码，出现错误时返回部分解码结果
    return utf8.decode(utf8Bytes, allowMalformed: true);
  }
}

/*

import 'dart:ffi';

class FriendEntity extends Struct {
  @Array<Char>(256)
  external Array<Char> name;

  @Array<Char>(256)
  external Array<Char> avatar;

  // 使用扩展方法，将 name 和 avatar 转换为 Dart 字符串
  String getName() => name.toDartString();
  String getAvatar() => avatar.toDartString();
}

 */