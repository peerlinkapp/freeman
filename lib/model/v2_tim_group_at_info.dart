

import '../common/utils.dart';

/// V2TimGroupAtInfo
///
/// {@category Models}
///
class V2TimGroupAtInfo {
  late String seq;
  late int atType;

  V2TimGroupAtInfo({
    required this.seq,
    required this.atType,
  });

  V2TimGroupAtInfo.fromJson(Map json) {
    json = Utils.formatJson(json);
    seq = json['seq'].toString();
    atType = json['atType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seq'] = seq;
    data['atType'] = atType;
    return data;
  }
  String toLogString() {
    String res = "seq:$seq|atType:$atType";
    return res;
  }
}

// {
//   "seq":0,
//   "atType":0
// }
