

import 'package:freeman/model/v2_tim_message_voice.dart';
import 'package:freeman/model/v2_tim_text_elem.dart';
import 'package:freeman/model/v2_tim_user_full_info.dart';

import '../common/utils.dart';
import 'v2_tim_img_elem.dart';
import 'v2_tim_message_file.dart';

/// V2TimMessageReceipt
///
/// {@category Models}
///

class V2TimMessage {

  /// 消息id, 消息表中的INT主键
  late int? id; //

  /// 消息随机ID
  late int? randID;

  /// 消息时间戳
  late int? timestamp;

  /// 消息发送进度，只有多媒体消息才会有，其余消息为100
  late int? progress;

  /// 消息发送者
  late String? sender;

  /// 消息发送者
  String? senderId = '';

  /// 消息发送者昵称
  late String? nickName;

  /// 消息发送者好友备注，只有当与消息发送者有好友关系，且给好友设置过备注，才会有值
  late String? friendRemark;

  /// 发送者头像
  late String? faceUrl;

  /// 发送者备注
  late String? nameCard;

  /// 群ID，只有群消息才会有
  late String? groupID;

  /// 消息接受者用户ID
  late String? userID;

  /// 消息状态 发送中 成功 失败等
  late int? status;

  /// 消息类型 文本消息 图片消息等
  late int elemType;

  /// 文本消息
  V2TimTextElem? textElem;

  /// 图片消息
  V2TimImageElem? imageElem;

  /// 文件消息
  V2TimFileElem? fileElem;

  /// 录音消息
  V2TimMessageVoiceElem? voiceElem;

/*
  /// 自定义消息
  V2TimCustomElem? customElem;

  /// 视频消息
  V2TimVideoElem? videoElem;

  /// 位置消息
  V2TimLocationElem? locationElem;

  /// 表情消息
  V2TimFaceElem? faceElem;

  /// 群提示消息
  V2TimGroupTipsElem? groupTipsElem;

  /// 合并消息
  V2TimMergerElem? mergerElem;

 */

  /// 消息的本地自定义字段（string类型），只存在于本地，删除应用后丢失
  late String? localCustomData;

  /// 消息的本地自定义字段（int 类型），只存在于本地，删除应用后丢失
  late int? localCustomInt;

  /// 消息的云端自定义字段（string类型）
  late String? cloudCustomData;

  /// 是否是当前登录用户的消息
  late bool? isSelf;

  /// 消息是否自己已读
  late bool? isRead;

  /// 消息是否接收方已读，仅c2c消息有效
  late bool? isPeerRead;

  /// 消息优先级
  late int? priority;

  /// 离线推送相关配置
  /*OfflinePushInfo? offlinePushInfo;*/

  /// 群@消息@数组
  List<String>? groupAtUserList = List.empty(growable: true);

  /// 消息序列号
  late String? seq;

  /// 合并消息
  late int? random;

  /// 消息是否计入会话未读数
  late bool? isExcludedFromUnreadCount;

  /// 消息是否计入会话lastmessage
  late bool? isExcludedFromLastMessage;

  /// 消息是否支持消息扩展
  late bool? isSupportMessageExtension;

  /// 来自web的消息，仅在flutter for web时有用
  late String? messageFromWeb;



  /// 是否要群消息已读回执
  late bool? needReadReceipt;

  /// 消息是否有风险内容
  bool? hasRiskContent;

  /// 消息撤回原因
  String? revokeReason;

  /// 是否是广播消息
  bool? isBroadcastMessage;

  /// 是否屏蔽消息内容审核
  bool? isExcludedFromContentModeration;

  /// 是否禁用消息发送前云端回调。true - 禁用，false - 不禁用
  bool? isDisableCloudMessagePreHook;

  /// 是否禁用消息发送后云端回调。true - 禁用，false - 不禁用
  bool? isDisableCloudMessagePostHook;

  /// 消息撤回者信息
  V2TimUserFullInfo? revokerInfo;

  V2TimMessage({
    this.randID,
    this.timestamp,
    this.progress,
    this.sender,
    this.senderId,
    this.nickName,
    this.friendRemark,
    this.faceUrl,
    this.nameCard,
    this.groupID,
    this.userID,
    this.status,
    required this.elemType,
    this.textElem,
  /*  this.customElem,
    this.imageElem,
    this.soundElem,
    this.videoElem,
    this.fileElem,
    this.locationElem,
    this.faceElem,
    this.groupTipsElem,
    this.mergerElem,*/
    this.localCustomData,
    this.localCustomInt,
    this.cloudCustomData,
    this.isSelf,
    this.isRead,
    this.isPeerRead,
    this.priority,
    //this.offlinePushInfo,
    this.groupAtUserList,
    this.seq,
    this.random,
    this.isExcludedFromUnreadCount,
    this.isExcludedFromLastMessage,
    this.isSupportMessageExtension,
    this.messageFromWeb,
    this.id,
    this.needReadReceipt,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is V2TimMessage && runtimeType == other.runtimeType && randID == other.randID && id == other.id && status == other.status;

  @override
  int get hashCode => randID.hashCode + id.hashCode + status.hashCode;

  V2TimMessage.fromJson(Map json) {
    json = Utils.formatJson(json);
    String? gid = json['groupID'] == "" ? null : json['groupID'];
    String? uid = json['userID'] == "" ? null : json['userID'];
    id = json['id'];
    randID = json['randID'];
    timestamp = json['timestamp'];
    progress = json['progress'];
    sender = json['sender'];
    nickName = json['nickName'];
    friendRemark = json['friendRemark'];
    faceUrl = json['faceUrl'];
    nameCard = json['nameCard'];
    groupID = gid;
    userID = uid;
    status = json['status'];
    elemType = json['elemType'] ?? 0;
    id = json['id'];
    needReadReceipt = json['needReadReceipt'];
    textElem = json['textElem'] != null ? V2TimTextElem.fromJson(json['textElem']) : null;
    imageElem = json['imageElem'] != null ? V2TimImageElem.fromJson(json['imageElem']) : null;
    fileElem = json['fileElem'] != null ? V2TimFileElem.fromJson(json['fileElem']) : null;
    voiceElem = json['voiceElem'] != null ? V2TimMessageVoiceElem.fromJson(json['voiceElem']) : null;
    /*customElem = json['customElem'] != null ? V2TimCustomElem.fromJson(json['customElem']) : null;
    videoElem = json['videoElem'] != null ? V2TimVideoElem.fromJson(json['videoElem']) : null;
    locationElem = json['locationElem'] != null ? V2TimLocationElem.fromJson(json['locationElem']) : null;
    faceElem = json['faceElem'] != null ? V2TimFaceElem.fromJson(json['faceElem']) : null;
    groupTipsElem = json['groupTipsElem'] != null ? V2TimGroupTipsElem.fromJson(json['groupTipsElem']) : null;
    mergerElem = json['mergerElem'] != null ? V2TimMergerElem.fromJson(json['mergerElem']) : null;*/
    localCustomData = json['localCustomData'] ?? "";
    localCustomInt = json['localCustomInt'];
    cloudCustomData = json['cloudCustomData'] ?? "";
    isSelf = json['isSelf'];
    isRead = json['isRead'];
    isPeerRead = json['isPeerRead'];
    priority = json['priority'];
    //offlinePushInfo = json['offlinePushInfo'] != null ? OfflinePushInfo.fromJson(json['offlinePushInfo']) : null;
    groupAtUserList = json['groupAtUserList'] != null ? json['groupAtUserList'].cast<String>() : List.empty(growable: true);
    seq = json['seq'];
    random = json['random'];
    isExcludedFromUnreadCount = json['isExcludedFromUnreadCount'];
    isExcludedFromLastMessage = json['isExcludedFromLastMessage'];
    isSupportMessageExtension = json["isSupportMessageExtension"];
    messageFromWeb = json['messageFromWeb'];

    hasRiskContent = json["hasRiskContent"];
    revokeReason = json["revokeReason"];
    isBroadcastMessage = json["isBroadcastMessage"];
    isExcludedFromContentModeration = json["isExcludedFromContentModeration"];
    isDisableCloudMessagePreHook = json['isDisableCloudMessagePreHook'];
    isDisableCloudMessagePostHook = json['isDisableCloudMessagePostHook'];
    revokerInfo = json['revokerInfo'] != null ? V2TimUserFullInfo.fromJson(json['revokerInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msgID'] = randID;
    data['randID'] = randID;
    data['isDisableCloudMessagePreHook'] = isDisableCloudMessagePreHook;
    data['isDisableCloudMessagePostHook'] = isDisableCloudMessagePostHook;
    data['timestamp'] = timestamp;
    data['progress'] = progress;
    data['sender'] = sender;
    data['nickName'] = nickName;
    data['friendRemark'] = friendRemark;
    data['faceUrl'] = faceUrl;
    data['nameCard'] = nameCard;
    data['groupID'] = groupID;
    data['userID'] = userID;
    data['status'] = status;
    data['elemType'] = elemType;
    data['id'] = id;
    data['needReadReceipt'] = needReadReceipt;
    if (textElem != null) {
      data['textElem'] = textElem!.toJson();
    }
    if (imageElem != null) {
      data['imageElem'] = imageElem!.toJson();
    }
    if (fileElem != null) {
      data['fileElem'] = fileElem!.toJson();
    }
    if (voiceElem != null) {
      data['voiceElem'] = voiceElem!.toJson();
    }
    /*if (customElem != null) {
      data['customElem'] = customElem!.toJson();
    }


    if (videoElem != null) {
      data['videoElem'] = videoElem!.toJson();
    }

    if (locationElem != null) {
      data['locationElem'] = locationElem!.toJson();
    }
    if (faceElem != null) {
      data['faceElem'] = faceElem!.toJson();
    }
    if (groupTipsElem != null) {
      data['groupTipsElem'] = groupTipsElem!.toJson();
    }
    if (mergerElem != null) {
      data['mergerElem'] = mergerElem!.toJson();
    }*/
    data['localCustomData'] = localCustomData;
    data['localCustomInt'] = localCustomInt;
    data['cloudCustomData'] = cloudCustomData;

    data['isSelf'] = isSelf;
    data['isRead'] = isRead;
    data['isPeerRead'] = isPeerRead;
    data['priority'] = priority;
    /*if (offlinePushInfo != null) {
      data['offlinePushInfo'] = offlinePushInfo!.toJson();
    }*/
    if (groupAtUserList != null) {
      data['groupAtUserList'] = groupAtUserList;
    }
    data['seq'] = seq;
    data['random'] = random;
    data['isExcludedFromUnreadCount'] = isExcludedFromUnreadCount;
    data['isExcludedFromLastMessage'] = isExcludedFromLastMessage;
    data["isSupportMessageExtension"] = isSupportMessageExtension;
    data['messageFromWeb'] = messageFromWeb;
    data["hasRiskContent"] = hasRiskContent;
    data["revokeReason"] = revokeReason;
    data["isBroadcastMessage"] = isBroadcastMessage;
    data["isExcludedFromContentModeration"] = isExcludedFromContentModeration;

    if (revokerInfo != null) {
      data['revokerInfo'] = revokerInfo!.toJson();
    } else {
      data['revokerInfo'] = null;
    }
    return data;
  }

  String toLogString() {
    var res =
        "|msgid:$randID|seq:$seq|random:$random|isSelf:$isSelf|sender$sender|timestamp:$timestamp|elemType:$elemType|groupID:$groupID|hasRiskContent:$hasRiskContent|isRead:$isRead|isPeerRead:$isPeerRead|cloudCustomData:$cloudCustomData|localCustomData:$localCustomData";
    return res;
  }
}
// {
//   "msgID":"",
//     "timestamp":0,
//     "progress":100,
//     "sender":"",
//     "nickName":"",
//     "friendRemark":"",
//     "faceUrl":"",
//     "nameCard":"",
//     "groupID":"",
//     "userID":"",
//     "status":1,
//     "elemType":1,
//     "textElem":{},
//     "customElem":{},
//     "imageElem":{},
//     "soundElem":{},
//     "videoElem":{},
//     "fileElem":{},
//     "locationElem":{},
//     "faceElem":{},
//     "groupTipsElem":{},
//     "mergerElem":{},
//     "localCustomData":"",
//     "localCustomInt":0,
//     "isSelf":false,
//     "isRead":false,
//     "isPeerRead":false,
//     "priority":0,
//     "offlinePushInfo":{},
//     "groupAtUserList":[{}],
//     "seq":0,
//     "random":0,
//     "isExcludedFromUnreadCount":false
// }
