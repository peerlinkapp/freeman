import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:lpinyin/lpinyin.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'binding_attach.dart';

import 'package:ffi/ffi.dart';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:freeman/binding_attach.dart';
import 'package:freeman/generated_bindings.dart';
import 'package:path_provider/path_provider.dart';
import 'common.dart';
import 'package:freeman/model/user.dart';
import 'model/conversations.dart';
import 'model/v2_tim_group_member_info.dart';
import 'model/v2_tim_user_full_info.dart';



class DhtClient with ChangeNotifier{
  late NativeLibrary bindings;
  var dhtClient; // freemanffi c++对象
  List<String> listFindUserResult = [];
  late String? _id;

  String? get id => _id;

  //即时消息 通过在class ChatDetailsBody类中使用StreamBuilder来更新界面
  final StreamController<String> _msgController = StreamController<String>.broadcast();
  Stream<String> get msgStream => _msgController.stream;
  StreamController<String> get msgController => _msgController;

  //消息发送状态监控
  final StreamController<String> _msgSendController = StreamController<String>.broadcast();
  Stream<String> get msgSendStream => _msgSendController.stream;
  StreamController<String> get msgSendController => _msgSendController;

  //文件发送状态监控
  final StreamController<String> _fileSendController = StreamController<String>.broadcast();
  Stream<String> get fileSendStream => _fileSendController.stream;
  StreamController<String> get fileSendController => _fileSendController;

  //用于通讯录刷新
  final StreamController<String> _friendsController = StreamController<String>.broadcast();
  Stream<String> get friendsStream => _friendsController.stream;
  StreamController<String> get friendsController => _friendsController;

  //用于查找用户界面刷新
  final StreamController<List<String>> _friendsFindController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get findStream => _friendsFindController.stream;

  //网络状态
  final StreamController<bool> _netController = StreamController<bool>.broadcast();
  Stream<bool> get netStream => _netController.stream;
  StreamController<bool> get netController => _netController;

  //动态
  final StreamController<String> _postController = StreamController<String>.broadcast();
  Stream<String> get postStream => _postController.stream;
  StreamController<String> get postController => _postController;

  DhtClient()
  {
    var dylibName = 'libfreemanffi.so';
    final dylib = File(dylibName);
    bindings = NativeLibrary(DynamicLibrary.open(dylibName));
  }

  Future<bool> init() async
  {
    initializeApiDL();

    Directory docDir =  await getApplicationDocumentsDirectory();
    dhtClient = bindings.dhtclient_create(docDir.path.toNativeUtf8().cast<Char>());

    setNetStatusNotify();
    return true;

  }

  void initializeApiDL()
  {
    bindings.ffi_Dart_InitializeApiDL(NativeApi.initializeApiDLData);
  }

  void setNetStatusNotify(){
    final receivePort = ReceivePort()
      ..listen((message){
        print("[dhtclient] NetStatusNotify: $message");
        bool avail = message[0];
        String statusDesc = "";
        statusDesc = avail ? Global.l10n.dht_net_avail: Global.l10n.dht_net_not_avail;
        Global.talker.info("network status:"+statusDesc);
        showGlobalToast(avail ? Global.l10n.dht_net_avail : Global.l10n.dht_net_not_avail);
        Global.settings.setDhtConnect(avail);
        netController.add(avail);  // 通过 Stream 更新消息
      });
    bindings.set_net_status_sendport(receivePort.sendPort.nativePort);

  }


  Future<bool> login(String user, String pwd) async
  {
    setNetStatusNotify();

    int ret = bindings.dhtclient_login(dhtClient, user.toNativeUtf8().cast<Char>(), pwd.toNativeUtf8().cast<Char>());
    bool ok = ret != 0;
    Global.talker.info("login");
    if(ok)
    {
      _id = get_id();
      setSendMsgNotify();
      setFileSentNotify();
      setRecvMsgNotify();
      setFindUserNotify();
      setAddMeNotify();
      setRecvApplyAddFriendResultNotify();
      setNewPostNotify();
    }
    return ok;
  }

  String get_id()
  {
    final ptr = bindings.dhtclient_getid(dhtClient);
    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值
    return result;
  }

  int get_userid()
  {
    return bindings.dhtclient_get_userid(dhtClient);
  }

  Future<bool> regist(String user, String pwd) async
  {
    int ret = bindings.dhtclient_regist(dhtClient, user.toNativeUtf8().cast<Char>(), pwd.toNativeUtf8().cast<Char>());
    return ret != 0;
  }

  Future<void> find_user(String user) async
  {

    listFindUserResult.clear();
    bindings.dhtclient_find_user(dhtClient, user.toNativeUtf8().cast<Char>());

  }

  bool sendAddFriendReply(String remoteid, bool allow)
  {
    bindings.dhtclient_send_apply_friend_reply(dhtClient, remoteid.toNativeUtf8().cast<Char>(), allow);
    _friendsController.add("contacts_page_refresh update");
    return true;
  }


  ContactType getContactType(int v)
  {
    ContactType ct = ContactType.pending;
    switch(v)
    {
      case 2: //WAIT_ME_REVIEW
        ct = ContactType.pending;
        break;
      case 4:
        ct = ContactType.rejected;
        break;
      case 5:
      case 6:
        ct = ContactType.approved;
        break;
    }
    return ct;
  }

  Contact getContactFromHashId(String uid)
  {
    Pointer<ContactEntity> ptr = calloc<ContactEntity>();

    bindings.dhtclient_get_contact_profile(dhtClient, uid.toNativeUtf8().cast<Char>(), ptr);
    Contact c = Contact(id: ptr.ref.id,
                  sex:ptr.ref.sex,
                  inviteCode: ptr.ref.inviteCode.toDartString(),
                  avatar: ptr.ref.avatar.toDartString(),
                  name: ptr.ref.name.toDartString(),
                  alias:ptr.ref.alias.toDartString(),
                  remark: ptr.ref.remark.toDartString(),
                  nameIndex: ptr.ref.name.toDartString(),
                  identifier: ptr.ref.hashid.toDartString(),
                  ctype: getContactType(ptr.ref.ftype),
            );
    //print("getContactFromId: uid=${uid}, ctype:${ptr.ref.ftype}, remark:${c.remark}");
    calloc.free(ptr);
    if(strEmpty(c.avatar))
    {
      switch(c.sex)
      {
        case 1:
          c.avatar = "assets/images/contact/Contact_Male.webp";
          break;
        case 2:
          c.avatar = "assets/images/contact/Contact_Female.webp";
          break;
        default:
          c.avatar = "assets/images/contact/Contact_Male.webp";
      }

    }
    return c;
  }

  List<Map<String, String>> getFriendList() {
    // 准备一个指针用于接收好友数量
    final countPointer = calloc<Int>();

    // 调用 getFriendList 函数
    final Pointer<ContactEntity> rawList = bindings.dhtclient_get_contacts(dhtClient, countPointer, 0);
    final int count = countPointer.value;

    // 转换为 Dart 的 List
    final List<Map<String, String>> friends = [];
    for (int i = 0; i < count; i++) {
      final entity = rawList.elementAt(i).ref;
      friends.add({
        'nickname': entity.name.toDartString(),
        'avatar': entity.avatar.toDartString(),
      });
    }

    // 释放分配的内存
    bindings.dhtclient_free_contacts(rawList);
    calloc.free(countPointer);

    return friends;
  }

  //key: 联系人姓名中包含的关键字，为空的话，返回所有人
  List<Contact> getContacts({ContactType ftype = ContactType.approved, String key = ""})
  {
    List<Contact> contacts = [];
    final countPointer = calloc<ffi.Int>();
    int ftype_v = 0;
    switch(ftype)
    {
      case ContactType.pending:
        ftype_v = 2;
        break;
      case ContactType.approved:
        ftype_v = 0;
        break;
      case ContactType.rejected:
        ftype_v = 3;
        break;
    }

    final contactListPointer = bindings.dhtclient_get_contacts(dhtClient, countPointer, ftype_v);
    final count = countPointer.value;

     // 遍历联系人数组
     for (var i = 0; i < countPointer.value; i++) {
       final entity = contactListPointer.elementAt(i).ref;
       String alias =  entity.alias.toDartString();
       String name =  entity.name.toDartString();
       if(alias.length>0)
       {
         name = alias;
       }
       if(name.length == 0) name = entity.hashid.toDartString();

       Contact contact = Contact(
         id:entity.id,
         sex:entity.sex,
         inviteCode: entity.inviteCode.toDartString(),
         avatar: entity.avatar.toDartString(),
         name: name,
         nameIndex: strNoEmpty(name)? name.substring(0, 1):"",
         alias: entity.alias.toDartString(),
         identifier: entity.hashid.toDartString(),
         updateTime: entity.updateTime,
         ctype: getContactType(entity.ftype)
       );
       //print("--------name:$name, alias:${contact.alias}, avatar:${contact.avatar}");
       if(strEmpty(contact.avatar))
       {
          switch(contact.sex)
          {
            case 1:
              contact.avatar = "assets/images/contact/Contact_Male.webp";
              break;
            case 2:
              contact.avatar = "assets/images/contact/Contact_Female.webp";
              break;
            default:
              contact.avatar = "assets/images/contact/Contact_Male.webp";

          }

       }

       if(!Utils.isEmptyStr(key))
       {
         if(name.contains(key!))
         {
           contacts.add(contact);
         }
       }else {
         contacts.add(contact);
       }
     }
    return contacts;
  }

  void setFindUserNotify(){
    final receivePort = ReceivePort()
    ..listen((message){
        //List to String
        String line = message.toString();
        if(!listFindUserResult.contains(line)) {
          listFindUserResult.add(line);
          _friendsFindController.sink.add(List.from(listFindUserResult));
        }
    });
    bindings.set_find_user_sendport(receivePort.sendPort.nativePort);

  }

  //收到加我好友的申请
  void setAddMeNotify(){
    final receivePort = ReceivePort()
      ..listen((message){
        String remoteid = message[0];
        print("[dhtclient] Recv APPLY_ADD_ME from: $remoteid");
        Global.talker.info("Recv APPLY_ADD_ME from: $remoteid");
        //仅通过_friendsController通知UI，以刷新通讯录
        _friendsController.add("APPLY_ADD_ME");
      });
    bindings.set_add_me_sendport(receivePort.sendPort.nativePort);

  }

  //收到我发送的加好友请求后，对端的回复
  void setRecvApplyAddFriendResultNotify()
  {
    final receivePort = ReceivePort()
      ..listen((message){

        var msg = jsonEncode(message);
        print("[dhtclient] Recv ADD_FRIEND_REPLY from: $msg");
        //Global.talker.info("Recv ADD_FRIEND_REPLY from: $remoteid");
        //仅通过_friendsController通知UI，以刷新通讯录
        _friendsController.add("ADD_FRIEND_REPLY");
      });
    bindings.set_recv_add_friend_result_sendport(receivePort.sendPort.nativePort);
  }

  //发送消息结果监控
  void setSendMsgNotify(){
    final receivePort = ReceivePort()
      ..listen((report){
        //print("[dhtclient] onSendMessage: $report");
        var _msg = jsonEncode(report);
        msgSendController.add(_msg);  // 通过 Stream 更新消息
      });

    bindings.set_msg_sent_sendport(receivePort.sendPort.nativePort);

  }

  //收到消息后，传递到UI
  void setRecvMsgNotify(){
    final receivePort = ReceivePort()
      ..listen((message){
        print("[dhtclient] onReceiveMessage: $message");
        var _msg = jsonEncode(message);
        Global.playNotificationSound();
        msgController.add(_msg);  // 通过 Stream 更新消息
      });
    bindings.set_recv_msg_sendport(receivePort.sendPort.nativePort);

  }

  //新帖到达，传递到UI
  void setNewPostNotify(){
    final receivePort = ReceivePort()
      ..listen((p){
        //参见 freemanffi.cpp on_new_post
        print("[dhtclient] newPosts: ${p[0]}, ${p[1]}, ${p[2]}, ${p[3]}, content:${p[5]}, isVisible:${p[11]}, isDeleted:${p[12]}");

        List<Post> posts = [];
        Post item = Post(
            id: p[0]
            , uuid: p[1]
            , userId: p[2]
            , userName: p[3]
            , userAvatar: p[4]
            , content: p[5]
            , comments: p[6]
            , likes: p[7]
            , views: p[8]
            , created_at: p[9]
            , updated_at: p[10]
            , isVisible: p[11]
            , isDeleted: p[12]
            , meVoted: p[13]
        );
        posts.add(item);
        // 转换为 List<Map<String, dynamic>>
        List<Map<String, dynamic>> postListJson = posts.map((post) => post.toJson()).toList();
        // 转换为 JSON 字符串
        String jsonString = jsonEncode(postListJson);
        postController.add(jsonString);
      });
    bindings.set_new_post_sendport(receivePort.sendPort.nativePort);
  }


  //发送文件结果监控
  void setFileSentNotify(){
    final receivePort = ReceivePort()
      ..listen((report){
        print("[dhtclient] setFileSentNotify: $report");
        var msg = jsonEncode(report);
        fileSendController.add(msg);  // 通过 Stream 更新消息
      });

    bindings.set_file_sent_sendport(receivePort.sendPort.nativePort);

  }
  //
  void sendAddFriendMsg(String hashid)
  {
    bindings.dhtclient_send_add_friend(dhtClient, hashid.toNativeUtf8().cast<Char>());
  }

  void addContact(String hashid, String name)
  {
    bindings.dhtclient_add_contact(dhtClient, hashid.toNativeUtf8().cast<Char>(), name.toNativeUtf8().cast<Char>());
    _friendsController.add("contacts_page_refresh add");
  }

  void delContact(String hashid)
  {
    bindings.dhtclient_del_contact(dhtClient, hashid.toNativeUtf8().cast<Char>());
    _friendsController.add("contacts_page_refresh del");
  }
  
  Future<int> sendMsg(int cid, String content) async
  {
    int msgid = 0;
    msgid  = bindings.dhtclient_send_msg(dhtClient, cid, content.toNativeUtf8().cast<Char>());
    List<dynamic> msg = [msgid, msgid, _id, content, DateTimeUtils.getEpochNow(), Global.user.avatar, 1, ""];
    _msgController.add(jsonEncode(msg));
    return msgid;
  }

  Future<int> sendImgMsg(String to, String imgfile) async{
    int msgid = 0;
    final ptrTo = to.toNativeUtf8().cast<Char>();
    final ptrImg = imgfile.toNativeUtf8().cast<Char>();

    try {
      msgid = bindings.dhtclient_send_img_msg(dhtClient, ptrTo, ptrImg);
      List<dynamic> msg = [msgid, msgid, _id, imgfile, DateTimeUtils.getEpochNow(), Global.user.avatar, MessageElemType.V2TIM_ELEM_TYPE_IMAGE.index, ""];
      _msgController.add(jsonEncode(msg));
    }catch(e) {
      print("发送图片消息时出错: $e");
    } finally {
      // 清理分配的内存
      calloc.free(ptrTo);
      calloc.free(ptrImg);
    }
    return msgid;

  }

  Future<int> sendFileMsg(String to, String filepath) async{
    int msgid = 0;
    final ptrTo = to.toNativeUtf8().cast<Char>();
    final ptrFile = filepath.toNativeUtf8().cast<Char>();

    File file = File(filepath);
    if (await file.exists()) {
      int sizeInBytes = await file.length();
      Map<String, dynamic> fj = {
        'filename': filepath,
        'totalBytes': sizeInBytes
      };

      String jsonStr = jsonEncode(fj);

      try {
        msgid = bindings.dhtclient_send_file(dhtClient, ptrTo, ptrFile);
        print("[sendFileMsg], msgid:${msgid}");
        List<dynamic> msg = [msgid, msgid, _id, jsonStr, DateTimeUtils.getEpochNow(), Global.user.avatar, MessageElemType.V2TIM_ELEM_TYPE_FILE.index, ""];
        _msgController.add(jsonEncode(msg));
      }catch(e) {
        print("发送文件消息时出错: $e");
      } finally {
        // 清理分配的内存
        calloc.free(ptrTo);
        calloc.free(ptrFile);
      }
    } else {
      print('文件不存在');
    }
    return msgid;
  }

  //发送语音消息
  Future<int> sendVoiceMsg(String to, String filepath) async{
    int msgid = 0;
    final ptrTo = to.toNativeUtf8().cast<Char>();
    final ptrFile = filepath.toNativeUtf8().cast<Char>();

    File file = File(filepath);
    if (await file.exists()) {
      try {
        msgid = bindings.dhtclient_send_audio_file(dhtClient, ptrTo, ptrFile);
        print("[sendVoiceMsg], msgid:${msgid}");
        List<dynamic> msg = [msgid, msgid, _id, filepath, DateTimeUtils.getEpochNow(), Global.user.avatar, MessageElemType.V2TIM_ELEM_TYPE_VOICE.index, ""];
        _msgController.add(jsonEncode(msg));
      }catch(e) {
        print("发送文件消息时出错: $e");
      } finally {
        // 清理分配的内存
        calloc.free(ptrTo);
        calloc.free(ptrFile);
      }
    } else {
      print('文件不存在');
    }
    return msgid;
  }

  String get_msg_file_path(int msgid)
  {
    final ptr = bindings.dhtclient_get_msg_file_path(dhtClient, msgid);
    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值
    return result;
  }

  //删除消息
  void delMsg(int id)
  {
    bindings.dhtclient_del_msg(dhtClient, id);
    List<String> fj = [];
    fj.add("del");
    fj.add(id.toString());
    String jsonStr = jsonEncode(fj);
    msgController.add(jsonStr);
  }

  List<Conversation> getConversationList() {
    // 准备一个指针用于接收好友数量
    final countPointer = calloc<Int>();

    // 调用 getFriendList 函数
    final Pointer<ConversationItem> rawList = bindings.dhtclient_get_conversations(dhtClient, countPointer);
    final int count = countPointer.value;

    // 转换为 Dart 的 List
    final List<Conversation> conversations = [];
    for (int i = 0; i < count; i++) {
      final entity = rawList.elementAt(i).ref;
      int cid = entity.id;
      List<Message> messages  = getMessageList(cid, 0, 1);

      String avatar = entity.faceUrl.toDartString();
      //如果会话本身无头像&对话联系人无头像
      if(avatar.length==0)
      {
        if(entity.isGroup == 1)
          {
            avatar = "assets/images/group/groupchat.png";
          }else {
            String remoteHashid = get_conversation_remote_id(cid);
            Contact contact = getContactFromHashId(remoteHashid);
            avatar = contact.avatar;
        }
      }
      //print("conversation:${cid}, avatar:${avatar}");
      Conversation item = Conversation(
          id: entity.id
          , showName: entity.showName.toDartString()
          , lastMsg: messages.length > 0 ? messages[0]: null
          , istop: entity.istop
          , isGroup: entity.isGroup
          , isPublic: entity.isPublic
          , isEnable: entity.isEnable == 1
          , faceUrl: avatar
          , unreadCount: entity.unreadCount
          , createTime: entity.createTime
      );

      conversations.add(item);
    }

    // 释放分配的内存
    bindings.dhtclient_free_conversations(rawList);
    calloc.free(countPointer);

    return conversations;
  }

  //获取群聊列表
  List<Conversation> getGroupList() {
    // 准备一个指针用于接收好友数量
    final countPointer = calloc<Int>();

    // 调用 getFriendList 函数
    final Pointer<ConversationItem> rawList = bindings.dhtclient_get_groups(dhtClient, countPointer);
    final int count = countPointer.value;

    // 转换为 Dart 的 List
    final List<Conversation> conversations = [];
    for (int i = 0; i < count; i++) {
      final entity = rawList.elementAt(i).ref;
      int cid = entity.id;

      List<Message> messages  = getMessageList(cid, 0, 1);

      String avatar = entity.faceUrl.toDartString();
      //如果会话本身无头像&对话联系人无头像
      if(avatar.length==0)
      {
        if(entity.isGroup == 1)
        {
          avatar = "assets/images/group/groupchat.png";
        }
      }

      String name = entity.showName.toDartString();
      Conversation item = Conversation(
          id: entity.id
          , showName: name
          , lastMsg: messages.length > 0 ? messages[0]: null
          , istop: entity.istop
          , isGroup: entity.isGroup
          , isPublic: entity.isPublic
          , isEnable: entity.isEnable == 1
          , faceUrl: avatar
          , unreadCount: entity.unreadCount
          , createTime: entity.createTime
          , nameIndex:  PinyinHelper.getFirstWordPinyin(name)[0].toUpperCase()
      );
      conversations.add(item);
    }

    // 释放分配的内存
    bindings.dhtclient_free_conversations(rawList);
    calloc.free(countPointer);

    return conversations;
  }

  List<Message> getMessageList(int conversationID, int offset, int count)
  {
    // 准备一个指针用于接收好友数量
    final countPointer = calloc<Int>();

    // 调用 getFriendList 函数
    final Pointer<MessageItem> rawList = bindings.dhtclient_get_messages(dhtClient, conversationID, offset, countPointer);
    final int count = countPointer.value;

    // 转换为 Dart 的 List
    final List<Message> messages = [];

    for (int i = 0; i < count; i++)
    {
        final entity = rawList.elementAt(i).ref;
        String senderHashid = entity.senderID.toDartString();
        String avatar = entity.senderAvatar.toDartString();
        if(strEmpty(avatar)) {
          Contact c =  getContactFromHashId(senderHashid);
          avatar = c.avatar;
        }

        Message item = Message(
            msgID: entity.msgID
            , randID: entity.randID
            , msgType:MessageElemType.values[entity.msgType]
            , conversationID:entity.conversationID.toString()
            , content: entity.content.toDartString()
            , senderID:senderHashid
            , senderName: entity.senderName.toDartString()
            , senderAvatar: avatar
            , updateTime: entity.updateTime
        );
        messages.add(item);

    }

    // 释放分配的内存
    bindings.dhtclient_free_messages(rawList);
    calloc.free(countPointer);

    return messages;
  }

  //获取会话的对端id
  String get_conversation_remote_id(int conv_id)
  {

    final ptr = bindings.dhtclient_get_remote_id(dhtClient, conv_id);

    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值
    return result;
  }

  T withCString<T>(String dartStr, T Function(Pointer<Utf8>) fn) {
    final ptr = dartStr.toNativeUtf8();
    try {
      return fn(ptr);
    } finally {
      calloc.free(ptr);
    }
  }

  int get_conversation_id(String remoteId)
  {
    return withCString(remoteId, (ptr) {
      return bindings.dhtclient_get_conv_id(dhtClient, ptr.cast<Char>());
    });
  }

  int createConversationC2C(String remoteId)
  {
    /*
    final remoteIdPtr = remoteId.toNativeUtf8(); // 分配内存
    int cid = bindings.dhtclient_create_conversation_c2c(dhtClient, remoteIdPtr.cast<Char>());
    calloc.free(remoteIdPtr); // 释放内存
    return cid;
    */
    return withCString(remoteId, (ptr) {
      return bindings.dhtclient_create_conversation_c2c(dhtClient, ptr.cast<Char>());
    });
  }

  Future<int> saveConversation(Conversation c) async
  {
    return createConversation(c.showName, c.announcement, c.members, c.isPublic == 1);
  }

  Future<int> createConversation(String title, String notice, List<int> members, bool isPublic) async
  {
    //debugPrint("[createConversation] members.count=${members.length}, isPublic:${isPublic}, notice:$notice}");
    final ptr = malloc<Uint64>(members.length);
    for (int i = 0; i < members.length; i++) {
      ptr[i] = members[i];
    }

    int cid = bindings.dhtclient_create_conversation(dhtClient
        , title.toNativeUtf8().cast<Char>()
        , notice.toNativeUtf8().cast<Char>()
        , ptr, members.length,
        isPublic
      );
    malloc.free(ptr);
    friendsController.add("createConversation");
    msgController.add("");
    return cid;
  }

  ConversationRole intToConversationRole(int index) {
    if (index < 0 || index >= ConversationRole.values.length) return ConversationRole.USER;
    return ConversationRole.values[index];
  }

  Future<Conversation> getConversationProfile(int cid) async
  {
    Pointer<ConversationItem> ptr = calloc<ConversationItem>();

    bindings.dhtclient_get_conversation_profile(dhtClient, cid, ptr);
    List<Message> messages  = getMessageList(cid, 0, 1);
    Conversation c = Conversation(
      id: ptr.ref.id
      , uuid: ptr.ref.uuid.toDartString()
      , showName: ptr.ref.showName.toDartString()
      , announcement: ptr.ref.announcement.toDartString()
      , lastMsg: messages.length > 0 ? messages[0]: null
      , istop: ptr.ref.istop
      , isGroup: ptr.ref.isGroup
      , isPublic: ptr.ref.isPublic
      , isEnable: ptr.ref.isEnable == 1
      , role: intToConversationRole(ptr.ref.role)
      , faceUrl: ptr.ref.faceUrl.toDartString()
      , unreadCount: ptr.ref.unreadCount
      , createTime: ptr.ref.createTime
    );
    calloc.free(ptr);
    return c;
  }

  Future<void> setGroupName(int cid, String name) async
  {
    final ptrV = name.toNativeUtf8().cast<ffi.Char>();
    bindings.dhtclient_set_group_name(dhtClient, cid,  ptrV);
    calloc.free(ptrV);
  }

  Future<void> setGroupNotice(int cid, String name) async
  {
    final ptrV = name.toNativeUtf8().cast<ffi.Char>();
    bindings.dhtclient_set_group_notice(dhtClient, cid,  ptrV);
    calloc.free(ptrV);
  }


  Future<int> groupAddMembers(int gid, List<int> ids) async
  {
    print("[groupAddMembers] ids:${ids.toString()}");
// 分配原生内存并复制 List<int> 数据
    final Pointer<Uint64> nativeArray = malloc.allocate<Uint64>(ids.length * sizeOf<Uint64>());
    for (var i = 0; i < ids.length; i++) {
      nativeArray[i] = ids[i];
    }
    final result = bindings.dhtclient_group_add_members(dhtClient, gid,nativeArray, ids.length);
    malloc.free(nativeArray); // 释放内存
    return result;
  }

  Future<void> groupDropMembers(int gid, List<int> ids) async
  {
    print("[groupDropMembers] ids:${ids.toString()}");
// 分配原生内存并复制 List<int> 数据
    final Pointer<Uint64> nativeArray = malloc.allocate<Uint64>(ids.length * sizeOf<Uint64>());
    for (var i = 0; i < ids.length; i++) {
      nativeArray[i] = ids[i];
    }
    bindings.dhtclient_group_drop_members(dhtClient, gid,nativeArray, ids.length);
    malloc.free(nativeArray); // 释放内存

  }

  Future<List<V2TimGroupMemberInfo>> getGroupMembers(int cid) async
  {
    List<V2TimGroupMemberInfo> results = [];
    final ptrCount = calloc<Int>();
    final Pointer<GroupUserInfo> rawList = bindings.dhtclient_get_group_members(dhtClient, cid, ptrCount);
    int count = ptrCount.value;

    for (int i = 0; i < count; i++) {
      final uinfo = rawList.elementAt(i).ref;
      V2TimGroupMemberInfo m = V2TimGroupMemberInfo(
          name: uinfo.name.toDartString(),
          userID:uinfo.userId,
          avatar: uinfo.avatar.toDartString()
      );
      if(strEmpty(m.avatar))
      {

            m.avatar = "assets/images/contact/Contact_Male.webp";

      }
      print("[getGroupMembers] name:${m.name}, id:${m.userID}, role:${uinfo.role}");
      results.add(m);
    }
    calloc.free(ptrCount);
    bindings.dhtclient_free_group_members(rawList);
    return results;
  }

  void clearConversation(int cid)
  {
    bindings.dhtclient_clear_conversation(dhtClient, cid);
    msgController.add("[clearConversation]");
  }


  Future<bool> delConversation(int id) async
  {
    String cid = id.toString();
    bool ret = bindings.dhtclient_del_conversation(dhtClient, cid.toNativeUtf8().cast<Char>());
    friendsController.add("delConversation");
    msgController.add("");
    return ret;
  }

  Future<bool> pinConversation(int id, int istop) async
  {
    String cid = id.toString();
    return bindings.dhtclient_pin_conversation(dhtClient, cid.toNativeUtf8().cast<Char>(), istop);
  }
  Future<bool> isConversationPinTop(int id) async
  {
    String cid = id.toString();
    return bindings.dhtclient_is_conversation_pintop(dhtClient, cid.toNativeUtf8().cast<Char>());
  }

  Future<bool> changeNickName(String nickname) async
  {
    print("changeNickName:${nickname}");
    return  bindings.dhtclient_change_nickname(dhtClient, nickname.toNativeUtf8().cast<Char>());
  }

  void setAvatar(String avatar)
  {
    return  bindings.dhtclient_set_avatar(dhtClient, avatar.toNativeUtf8().cast<Char>());
  }

  void setSex(int val)
  {
    bindings.dhtclient_set_sex(dhtClient, val);
  }

  void setSlogan(String txt)
  {
    final ptr =txt.toNativeUtf8().cast<Char>();
    bindings.dhtclient_set_slogan(dhtClient, ptr);
    calloc.free(ptr);
  }

  //获取普通用户资料信息
  Future<V2TimUserFullInfo> getContactProfile(int userid) async {

    V2TimUserFullInfo u = V2TimUserFullInfo();

    Pointer<ContactEntity> ptr = calloc<ContactEntity>();
    bindings.dhtclient_get_contact_profile2(dhtClient, userid, ptr);
    u.userID = userid;
    u.nickName  = ptr.ref.name.toDartString();
    u.faceUrl = ptr.ref.avatar.toDartString();
    u.gender = ptr.ref.sex;
    calloc.free(ptr);

    if(strEmpty(u.faceUrl))
    {
      switch(u.gender)
      {
        case 1:
          u.faceUrl = "assets/images/contact/Contact_Male.webp";
          break;
        case 2:
          u.faceUrl = "assets/images/contact/Contact_Female.webp";
          break;
        default:
          u.faceUrl = "assets/images/contact/Contact_Male.webp";
      }
    }
    print("[getContactProfile] id=${u.userID}, name:${u.nickName}, faceUrl:${u.faceUrl}");
    return  u;
  }

  //通过hashid，返回User实例
  User getUser(String hashid)
  {
    final hashPtr =hashid.toNativeUtf8().cast<Char>();
    User user = User();
    final Pointer<UserEntity> userPtr = calloc<UserEntity>();
    bindings.dhtclient_get_user_profile(dhtClient, hashPtr, userPtr);
    user.setUsername(userPtr.ref.name.toDartString());
    user.setUserId(hashid);
    user.setAvatar(userPtr.ref.avatar.toDartString());
    user.setSex(userPtr.ref.sex);
    user.setSlogan(userPtr.ref.slogan.toDartString());
    user.setAddMeMode(userPtr.ref.addme_mode);
    calloc.free(userPtr);
    calloc.free(hashPtr);
    return user;
  }

  String getUserDataPath()
  {
    final ptr = bindings.dhtclient_get_user_path(dhtClient);
    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //
    return result;
  }

  void setAddMeMode(int val)
  {
    return  bindings.dhtclient_set_addmemode(dhtClient, val);
  }

  int getAddMeMode()
  {
    return  bindings.dhtclient_get_addmemode(dhtClient);
  }
  void exeSql(String sql)
  {
    if (dhtClient == nullptr ) {
      print("dhtClient is null, cannot execute SQL");
      return;
    }
    final ptr = sql.toNativeUtf8().cast<Char>();
    bindings.dhtclient_sql(dhtClient, ptr);
    calloc.free(ptr);
  }

  Future<void> createP2P(String remoteid) async
  {
    final ptr = remoteid.toNativeUtf8().cast<Char>();
    bindings.dhtclient_create_p2p(dhtClient, ptr);
    calloc.free(ptr);
  }

  String getRemoteStats(String remoteid) {
    final cidPtr = remoteid.toNativeUtf8().cast<ffi.Char>();
    final ptr = bindings.dhtclient_get_remote_stats(dhtClient, cidPtr);
    calloc.free(cidPtr); //  释放 remoteid 的 native 内存

    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值

    return result;
  }

  Future<void> delPost(int id) async
  {
    bindings.dhtclient_del_post(dhtClient, id);
  }

  Future<bool> upvotePost(int id) async
  {
     return bindings.dhtclient_upvote_post(dhtClient, id);
  }

  Future<bool> replyPost(int id, int parent_id, String content) async
  {
    final ptrTxt = content.toNativeUtf8().cast<ffi.Char>();
    final ret = bindings.dhtclient_reply_post(dhtClient, id, parent_id, ptrTxt);
    calloc.free(ptrTxt);
    return ret;
  }

  Future<void> delReply(int id) async
  {
    bindings.dhtclient_del_reply(dhtClient, id);
  }

  Future<bool> upvoteReply(int id) async
  {
    return bindings.dhtclient_upvote_reply(dhtClient, id);
  }

  Future<int> savePost(int postId, List<int> bytes) async
  {
    final dataPtr = calloc<ffi.Uint8>(bytes.length);
    final byteList = Uint8List.fromList(bytes);

    for (int i = 0; i < bytes.length; i++) {
      dataPtr[i] = byteList[i];
    }

    final written = bindings.dhtclient_write_post(dhtClient, postId, dataPtr, bytes.length);
    calloc.free(dataPtr);
    return written;
  }

  Future<List<Post>>  getPosts(int postType, int userid, int offset, int count) async
  {
      debugPrint("[dhtclient] getPosts postType=${postType}, userid=$userid, offset=$offset, count=$count");
      // 准备一个指针用于接收好友数量
      final countPointer = calloc<Int>();
      countPointer.value = count;

      // 调用 getFriendList 函数
      final Pointer<PostItem> rawList = bindings.dhtclient_get_posts(dhtClient, postType, userid, offset, countPointer);
      final int count_ret = countPointer.value;

      // 转换为 Dart 的 List
      final List<Post> posts = [];

      for (int i = 0; i < count_ret; i++) {
        final entity = rawList.elementAt(i).ref;
        //print("[getPosts] post id:${entity.id} visible:${entity.isVisible} deleted:${entity.isDeleted}");
        Post item = Post(
            id: entity.id
            , uuid: entity.uuid.toDartString()
            , userId: entity.userId
            , userName: entity.userName.toDartString()
            , userAvatar: entity.userAvatar.toDartString()
            , content: entity.content.toDartString()
            , comments: entity.comments
            , likes: entity.likes
            , views: entity.views
            , created_at: entity.created_at
            , updated_at: entity.updated_at
            , isDeleted: entity.isDeleted
            , isVisible: entity.isVisible
            , meVoted: entity.meVoted
        );
        if(!entity.isDeleted && entity.isVisible) {
          posts.add(item);
        }
      }

      // 释放分配的内存
      bindings.dhtclient_free_posts(rawList);
      calloc.free(countPointer);

      // 转换为 List<Map<String, dynamic>>
      List<Map<String, dynamic>> postListJson = posts.map((post) => post.toJson()).toList();
      // 转换为 JSON 字符串
      String jsonString = jsonEncode(postListJson);
      postController.add(jsonString);

      print("getPosts: offset=$offset, count=$count, result:${posts.length}");
      return posts;
  }

  Future<List<Comment>> getPostReplys(int post_id) async
  {
    debugPrint("[getPostReplys] post_id=${post_id} ");
    final countPointer = calloc<Int>();
    final Pointer<PostItem> rawList = bindings.dhtclient_get_post_replys(dhtClient, post_id, countPointer);
    final int count  = countPointer.value;

    // 转换为 Dart 的 List
    final List<Comment> posts = [];

    for (int i = 0; i < count; i++) {
      final entity = rawList.elementAt(i).ref;

      Comment item = Comment(
          id: entity.id
          //, uuid: entity.uuid.toDartString()
          //, userId: entity.userId
          , user: entity.userName.toDartString()
         // , userAvatar: entity.userAvatar.toDartString()
          , content: entity.content.toDartString()
          , parentId: entity.parentId
          , likes: entity.likes
          , meVoted: entity.meVoted
          , created_at: entity.created_at
      );

      print("[getPostReplys] id:${item.id} parent:${item.parentId} user:${item.user} content:${entity.content.toDartString()} created_at:${entity.created_at}");
      //if(!entity.isDeleted && entity.isVisible) {
        posts.add(item);
      //}
    }

    // 释放分配的内存
    bindings.dhtclient_free_posts(rawList);
    calloc.free(countPointer);

    print("[getPostReplys]  result:${posts.length}");
    return posts;
  }

  String getInviteCode() {
    final ptr = bindings.dhtclient_get_invite_code(dhtClient);
    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值
    return result;
  }

  String regenInviteCode() {
    final ptr = bindings.dhtclient_regen_invite_code(dhtClient);
    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值
    return result;
  }

  void setMessagesReaded(int cid)
  {
    bindings.dhtclient_set_messages_read(dhtClient, cid);
  }

  int getMessagesUnread(int cid)
  {
    return bindings.dhtclient_get_messages_unread(dhtClient, cid);
  }

  String getCfg(String key)
  {
    final ptrKey = key.toNativeUtf8().cast<ffi.Char>();
    final ptr = bindings.dhtclient_get_cfg(dhtClient, ptrKey);
    calloc.free(ptrKey);
    final result = ptr.cast<Utf8>().toDartString();
    bindings.dhtclient_free_string(ptr); //  正确释放 strdup 返回值

    return result;
  }

  void setCfg(String key, String value)
  {
    final ptrKey = key.toNativeUtf8().cast<ffi.Char>();
    final ptrValue = value.toNativeUtf8().cast<ffi.Char>();
    bindings.dhtclient_set_cfg(dhtClient, ptrKey, ptrValue);
    calloc.free(ptrKey);
    calloc.free(ptrValue);
  }

  //修改联系人别名
  void setContactAlias(int userid, String alias)
  {
    final ptrV = alias.toNativeUtf8().cast<ffi.Char>();
    bindings.dhtclient_set_contact_alias(dhtClient, userid,  ptrV);
    calloc.free(ptrV);
    friendsController.add("contacts_page_update");
  }

  //修改联系人备注
  void setContactRemark(int userid, String alias)
  {
    final ptrV = alias.toNativeUtf8().cast<ffi.Char>();
    bindings.dhtclient_set_contact_remark(dhtClient, userid,  ptrV);
    calloc.free(ptrV);
  }

  //
  bool isContactP2P(String hashid)
  {
    bool ret = false;
    final ptrV = hashid.toNativeUtf8().cast<ffi.Char>();
    ret = bindings.dhtclient_is_contact_p2p(dhtClient,  ptrV);
    calloc.free(ptrV);
    return ret;
  }
}