import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'package:freeman/model/v2_tim_img_elem.dart';
import 'package:freeman/model/v2_tim_message_voice.dart';
import 'v2_tim_message.dart';
import 'v2_tim_elem.dart';
import 'v2_tim_message_file.dart';

//聊天消息数据加载




class ChatDataRep {

  static V2TimMessage getTimFromMsg(Message msg)
  {
    String avatar = msg.senderAvatar ?? "";
    if(!strNoEmpty(avatar) && msg.senderID == Global.user.uuid)
    {
      avatar = Global.user.avatar;
    }

      V2TimMessage tim =  V2TimMessage(
          elemType: msg.msgType.index,
          faceUrl: avatar,
          timestamp: msg.updateTime,
          nickName: msg.senderName,
          randID:msg.randID,
          id:msg.msgID,
          sender: msg.senderName,
          senderId: msg.senderID
      );

      if(msg.msgType == MessageElemType.V2TIM_ELEM_TYPE_TEXT)
      {
        V2TimTextElem ele = V2TimTextElem(text: msg.content);
        tim.textElem = ele;
      }else if(msg.msgType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE)
      {
        V2TimImage img = V2TimImage();
        img.setUrl(msg.content);
        List<V2TimImage> list = [];
        list.add(img);
        V2TimImageElem ele = V2TimImageElem(imageList: list);
        tim.imageElem = ele;
      }else if(msg.msgType == MessageElemType.V2TIM_ELEM_TYPE_FILE)
      {
          /**/
          try{
            tim.fileElem = V2TimFileElem.fromJson(json.decode(msg.content));
          } catch (e) {
            print("发生异常: $e");
            Map<String, dynamic> jsonData = {
              "filename": "",
              "totalBytes": 0
            };
            String jsonString = json.encode(jsonData);
            tim.fileElem = V2TimFileElem.fromJson(json.decode(jsonString));
          }
      }else if(msg.msgType == MessageElemType.V2TIM_ELEM_TYPE_VOICE) {
          tim.voiceElem = V2TimMessageVoiceElem(filename:msg.content);
      }

      return tim;
  }


  repData(int cid) async {

    List<V2TimMessage> chatData = [];
    //从数据库中读取聊天记录
    List<Message> msgs = await  Global.getMessages(cid, 0, 100);

    msgs.forEach((msg) {
      V2TimMessage tim = getTimFromMsg(msg);
      chatData.insert( 0,tim );
    });

    /*
     final chatMsgData = "[{\"message\":\"aaa\",\"timeStamp\":\"sss\"}, {\"message\":\"aaa2\",\"timeStamp\":\"sss\"}]";
      List chatMsgDataList = json.decode(chatMsgData);
      for (int i = 0; i < chatMsgDataList.length; i++) {
        chatData.insert(
          0,
          new ChatData(
            msg: chatMsgDataList[i]['message'],
            avatar: "",
            time: chatMsgDataList[i]['timeStamp'],
            nickName: "model.nickName",
            id: "model.identifier",
          ),
        );
      }*/

    /*
    for (int i = 0; i < 10; i++) {
      chatData.insert(
        0,
        new ChatData(
          msg: {"type": "Text", "text":"aaaaaaaaaa"+i.toString()},
          avatar: "",
          time: 2123423,
          nickName: "model.nickName",
          id: "ad14d5dafaadcc6f54592e487fd275240bdbf148",
          sender: "ad14d5dafaadcc6f54592e487fd275240bdbf148"
        ),
      );
    }

    chatData.insert(
      0,
      new ChatData(
        msg: {"type": "Text", "text":"bbb"},
        avatar: "",
        time: 2123425,
        nickName: "model.nickName",
        id: "7d14d5dafaadcc6f54592e487fd275240bdbf148",
        sender: "7d14d5dafaadcc6f54592e487fd275240bdbf148",
      ),
    );
    */
    return chatData;
  }
}
