

import '../common/utils.dart';

/// V2TimGroupAtInfo
///
/// {@category Models}
///
class V2TimGroupMemberInfo {

  late int userID;
  late String name;
  late String avatar;


  V2TimGroupMemberInfo({
    required this.userID,
    required this.name,
    required this.avatar
  });

  V2TimGroupMemberInfo.fromJson(Map json) {
    json = Utils.formatJson(json);
    name = json['name'].toString();
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['avatar'] = avatar;
    return data;
  }
  String toLogString() {
    String res = "name:$name|avatar:$avatar";
    return res;
  }
}
