
import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'dart:convert';
import 'package:freeman/constants.dart';
import '../global.dart';


/*

// 模拟 JSON 数据
  List<Map<String, dynamic>> jsonData = [
    {'avatar': 'avatar1.png', 'name': 'Alice', 'nameIndex': 'A', 'identifier': '001'},
    {'avatar': 'avatar2.png', 'name': 'Bob', 'nameIndex': 'B', 'identifier': '002'},
    {'avatar': 'avatar3.png', 'name': 'Charlie', 'nameIndex': 'C', 'identifier': '003'},
  ];

  // 将 JSON 数据转换为 List<Contact>
  List<Contact> contacts = jsonData.map((json) => Contact.fromJson(json)).toList();

  printContacts(contacts);

  void printContacts(List<Contact> contacts) {
  for (var contact in contacts) {
    print('Name: ${contact.name}, Identifier: ${contact.identifier}');
  }
}
 */

enum ContactType { pending, approved, rejected }

class Contact {
  Contact({
    required this.avatar,
    required this.name,
    required this.nameIndex,
    required this.identifier, //uuid
    required this.id,
    this.updateTime,
    this.ctype,
    this.alias = "",
    this.sex = 0,
    this.inviteCode = "",
    this.remark = ""
  });

  late String avatar;
  final String name;
  final String nameIndex;
  final String identifier;
  final String inviteCode;
  final String alias;
  late String remark;
  late int? updateTime;
  late int id;
  late int sex;

  late ContactType? ctype;


  factory Contact.fromHashID(String hashid)
  {
    return Global.dhtClient.getContactFromHashId(hashid);
  }
  // 从 JSON 构建 Contact 对象
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id:json['id'],
      avatar: json['avatar'],
      name: json['name'],
      nameIndex: json['nameIndex'],
      identifier: json['identifier'],
    );
  }
  // 将 Contact 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'name': name,
      'nameIndex': nameIndex,
      'identifier': identifier,
    };
  }
}

class ContactsPageData {
  Future<bool> contactIsNull() async {
    List<Contact> contacts = await Global.getContacts();
    return contacts.isEmpty;
  }

  Future<List<Contact>> listFriend(ContactType ftypev) async {

    List<Contact> contactList = await  Global.getContacts(ftype: ftypev);
    return contactList;
  }


}
