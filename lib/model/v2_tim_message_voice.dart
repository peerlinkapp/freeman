import 'dart:convert';
import 'package:freeman/model/v2_tim_elem.dart';
import '../common/utils.dart';

class V2TimMessageVoiceElem extends V2TIMElem {

  String? filename = "";

  V2TimMessageVoiceElem({
    required this.filename,
    Map<String, dynamic>? nextElem,
  }) : super(nextElem: nextElem);

  V2TimMessageVoiceElem.fromJson(Map json) {
    json = Utils.formatJson(json);
    filename = json['filename'];
    if (json['nextElem'] != null) {
      nextElem = Utils.formatJson(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
