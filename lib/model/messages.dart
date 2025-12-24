
import 'dart:ffi';

import 'package:freeman/common.dart';

import 'message_elem_type.dart';



/*

// 模拟 JSON 数据
  List<Map<String, dynamic>> jsonData = [
    {'avatar': 'avatar1.png', 'name': 'Alice', 'nameIndex': 'A', 'identifier': '001'},
    {'avatar': 'avatar2.png', 'name': 'Bob', 'nameIndex': 'B', 'identifier': '002'},
    {'avatar': 'avatar3.png', 'name': 'Charlie', 'nameIndex': 'C', 'identifier': '003'},
  ];

  // 将 JSON 数据转换为 List<Contact>
  List<Conversation> contacts = jsonData.map((json) => Contact.fromJson(json)).toList();

  printContacts(contacts);

  void printContacts(List<Contact> contacts) {
  for (var contact in contacts) {
    print('Name: ${contact.name}, Identifier: ${contact.identifier}');
  }
}
 */
class Message {
  Message({
    required this.msgID,  //主键
    required this.msgType,
    required this.conversationID,
    required this.content,
    required this.randID, //随机整值
    required this.senderID,
    required this.updateTime,
    this.senderName,
    this.senderAvatar
  });

  final int msgID; //主键
  final int randID; //用于区分唯一性的随机整型
  final MessageElemType msgType;
  final String conversationID;
  final String content;
  final String senderID; //发送者ID
  final int updateTime;
  final String? senderName;
  final String? senderAvatar;


  // 从 JSON 构建 Conversation 对象
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      msgID: json['id'],
      msgType: json['remoteID'],
      conversationID: json['localID'],
      content: json['content'],
      randID: json['randID'],
      senderID:json['senderID'],
      updateTime:json['updateTime']
    );
  }
}

class MessagesPageData {
  Future<bool> messagesIsNull(int conversationID) async {
    List<Message> result = await Global.getMessages(conversationID, 0, 0);
    return result.isEmpty;
  }

  listMessages(int conversationID) async {


    getMethod() async {
      List<Message> result = await  Global.getMessages(conversationID,0, 0);
      return result;
    }

    return await getMethod();
  }
}
