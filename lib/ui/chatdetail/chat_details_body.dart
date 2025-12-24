import 'dart:convert';
import 'dart:async';

import 'package:freeman/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freeman/ui/chatdetail/send_message_view.dart';

import '../../model/v2_tim_img_elem.dart';
import '../../model/v2_tim_message.dart';
import '../../model/v2_tim_elem.dart';
import '../../model/v2_tim_message_file.dart';
import '../../model/v2_tim_message_voice.dart';


//chat_page聊天详情页中的消息列表，通过StreamBuilder实现消息收到后，界面实时刷新
class ChatDetailsBody extends StatefulWidget {
  final ScrollController sC;
  final int cid;

  ChatDetailsBody({super.key, required this.sC, required this.cid});

  @override
  ChatDetailsBodyState createState() => ChatDetailsBodyState();
}

class ChatDetailsBodyState extends State<ChatDetailsBody> {
  late List<V2TimMessage> _chatData = [];
  StreamSubscription<String>? _subscription;

  Future getChatMsgData() async {
    final chats = await ChatDataRep().repData(widget.cid );
    List<V2TimMessage> listChat = chats;
    _chatData.clear();
    _chatData..addAll(listChat.reversed.toList());
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //获取消息列表
    getChatMsgData();
    // 监听 msgStream，收到新消息后处理插入逻辑
    _subscription = Global.dhtClient.msgStream.listen((msg) {
      debugPrint("[ChatDetailsBody] new msg Data: $msg");
      handleIncomingMsg(msg);
    });

  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  void handleIncomingMsg(String rawMsg) {
    List<dynamic> parsedList = List<dynamic>.from(jsonDecode(rawMsg));
    int count = parsedList.length;

    // 删除消息
    if (count == 2) {
      if (parsedList[0] == "del") {
        _chatData.removeWhere((m) => m.id == Utils.StringToInt(parsedList[1]));
        setState(() {});
      }
      return;
    }

    var msgId = parsedList[0];
    var randId = parsedList[1];
    String sender = parsedList[2];
    String content = parsedList[3];
    int recvTime = parsedList[4];
    String avatar = parsedList[5];
    int msgType = parsedList[6]; // DhtMessageType
    String ext = parsedList[7];

    if (sender == Global.user.uuid) {
      avatar = Global.user.avatar;
    }

    bool exist = _chatData.any((msg) => msg.randID == randId);

    V2TimMessage tim = new V2TimMessage(
      id: msgId,
      randID: randId,
      faceUrl: avatar,
      timestamp: recvTime,
      nickName: sender,
      sender: sender,
      senderId: sender,
      elemType: msgType,
    );
    MessageElemType msgEnum;
    if (msgType >= 0 && msgType < MessageElemType.values.length) {
      msgEnum = MessageElemType.values[msgType];
    } else {
      // 假定枚举中存在 V2TIM_ELEM_TYPE_NONE
      msgEnum = MessageElemType.V2TIM_ELEM_TYPE_NONE;
    }

    switch (msgEnum) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        tim.textElem = V2TimTextElem(text: content);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        V2TimImage img = V2TimImage();
        img.setUrl(content);
        tim.imageElem = V2TimImageElem(imageList: [img]);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        Map<String, dynamic> data = jsonDecode(content);
        tim.fileElem = V2TimFileElem(
          totalBytes: data['totalBytes'],
          filename: getFileName(data['filename']),
        );
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_P2P:
        tim.textElem = V2TimTextElem(text: content);
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VOICE:
        tim.voiceElem = V2TimMessageVoiceElem(filename: content);
        break;
      default:
      // 未知类型，作为文本回退
        tim.textElem = V2TimTextElem(text: content);
        break;
    }

    if (!exist && sender.isNotEmpty) {
      // 深拷贝：先转成 JSON，再反序列化成一个新对象
     /* final copy = V2TimMessage.fromJson(
          jsonDecode(jsonEncode(tim.toJson())) as Map<String, dynamic>
      );*/
      setState(() {
        _chatData.insert(0, tim);
      });
    }
  }

  Widget msgListWidget()
  {
    print("[ChatDetailsBodyState::msgListWidget] length:${_chatData.length}");
    return  ListView.builder(
      controller: widget.sC,
      padding: EdgeInsets.all(8.0),
      reverse: true,
      itemBuilder: (context, int index) {
        V2TimMessage model = _chatData[index];
        V2TimMessage model_pre; //上一条消息（旧）
        if(index+1 ==  _chatData.length) {
          model_pre = V2TimMessage(elemType: 0,  timestamp: 0, senderId: "");
        }else{
          model_pre = _chatData[index + 1];
        }
        //int diff = model.time! - model_pre.time!;
        return new SendMessageView(key: ValueKey(model.randID), model:model, model_pre:model_pre);
      },
      itemCount: _chatData.length,
      dragStartBehavior: DragStartBehavior.down,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: msgListWidget(),
      ),
    );
  }

}
