
import 'package:freeman/common.dart';
import 'v2_tim_group_member_info.dart';

enum ConversationRole {
  // 普通用户
  USER,
  OWNER, //谁的会话
  ADMIN,
  CREATOR
}

class Conversation {

  final int id;
  String uuid;
  String showName;
  String nameIndex;
  final Message? lastMsg;
  int istop;
  int isPublic; //是否公开
  int isGroup; //是否群聊
  bool isEnable;
  ConversationRole role;
  int createTime; //创建日期
  String? faceUrl;
  late String announcement;

  late int unreadCount;
  late List<int> members = []; // 成员列表（可用 String 表示用户ID或用户名）

  Conversation({
    required this.id,
    required this.showName,
    this.nameIndex = '',
    this.uuid = '',
    this.istop = 0,
    this.lastMsg,
    this.isPublic = 0,
    this.isGroup = 0,
    this.isEnable = false,
    this.faceUrl,
    this.unreadCount = 0,
    this.createTime = 0,
    this.announcement = ' ',
    this.members = const [],
    this.role = ConversationRole.USER
  });





  // 从 JSON 构建 Conversation 对象
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      isPublic: json['isPublic'],
      isGroup: json['isGroup'],
      showName: json['showName'],
      lastMsg: json['lastMsg'],
      istop: json['istop']
    );
  }

  static getMemberUserProfiles(int groupId) async {

    List<V2TimGroupMemberInfo> gm = await Global.dhtClient.getGroupMembers(groupId);
    List<Contact> contactList = [];

    gm.forEach((m){
      Contact c = Contact(id: m.userID, name: m.name, nameIndex: m.name, avatar: m.avatar, identifier: m.userID.toString());
      contactList.add(c);
    });

    return contactList;

  }
}

class ConversationPageData {
  Future<bool> conversationIsNull() async {
    List<Conversation> result = await Global.getConversations();
    return result.isEmpty;
  }

  listConversation() async {

    getMethod() async {
      List<Conversation> result = await  Global.getConversations();
/*
      for (int i = 0; i < ccc.length; i++) {
          avatar = "";
          identifier = "sss"+i.toString();
          remark = "";
          nickName = ccc[i].nickname;
          nickName = !strNoEmpty(nickName) ? identifier : nickName;
          contacts.insert(
            0,
            new Contact(
              avatar: !strNoEmpty(avatar) ? defIcon : avatar,
              name: !strNoEmpty(remark) ? nickName : remark,
              nameIndex:
              //PinyinHelper.getFirstWordPinyin("我")[0].toUpperCase(),
              "s",
              identifier: identifier,
            ),
          );

      }
      return contacts;*/
      return result;
    }

    return await getMethod();
  }
}


Future<void> clearConversation(String id) async {
  int cid = Utils.StringToInt(id);
  Global.dhtClient.clearConversation(cid);
}

Future<void> deleteConversation(String id) async {
  int cid = Utils.StringToInt(id);
  Global.dhtClient.delConversation(cid);
}

