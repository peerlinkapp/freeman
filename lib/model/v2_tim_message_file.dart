import 'dart:convert';
import 'package:freeman/model/v2_tim_elem.dart';
import '../common/utils.dart';

class V2TimFileElem extends V2TIMElem {
  final int totalBytes;
  final String filename;

  V2TimFileElem({
    required this.totalBytes,
    required this.filename,
    Map<String, dynamic>? nextElem,
  }) : super(nextElem: nextElem);

  factory V2TimFileElem.fromJson(Map<String, dynamic> json) {
    final formattedJson = Utils.formatJson(json);

    return V2TimFileElem(
      totalBytes: formattedJson['totalBytes'] ?? 0,
      filename: getFileName(formattedJson['filename']) ?? '',
      nextElem: formattedJson['nextElem'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }

  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
  String toLogString() {
    String res = "";
    return res;
  }
}

// {
//   "text":""
// }
