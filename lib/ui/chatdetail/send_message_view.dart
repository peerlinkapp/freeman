import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freeman/common.dart';

import '../../model/chat_data.dart';
import '../../model/v2_tim_message.dart';
import 'text_msg.dart';
import 'img_msg.dart';
import 'file_msg_view.dart';
import 'voice_play_widget.dart';

class SendMessageView extends StatefulWidget {
  final V2TimMessage model;
  final V2TimMessage model_pre;

  SendMessageView({Key? key, required this.model, required this.model_pre}) : super(key: key);

  @override
  _SendMessageViewState createState() => _SendMessageViewState();
}

class _SendMessageViewState extends State<SendMessageView> {

  Widget getWidgetWithTime(BuildContext context, V2TimMessage data, V2TimMessage data_pre){

    String updatetime = DateTimeUtils.getHumanReadableDate(data.timestamp ?? DateTimeUtils.getEpochNow());
    bool ignoreMin = DateTimeUtils.areNeighbourMinute(data.timestamp ?? DateTimeUtils.getEpochNow(), data_pre.timestamp!);

    if(ignoreMin)
      {
        return getWidgetWithoutTime(context, data);
      }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          // 时间显示
          Center(
            child: Text(
              updatetime,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          // 消息显示
          getWidgetWithoutTime(context, data)
        ],
      ),
    );

  }

  Widget getWidgetWithoutTime(BuildContext context, V2TimMessage msg) {

    if (msg.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT.index) {
      return new TextMsg(msg.textElem!.text!, widget.model);
    } else if (msg.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE.index) {
      return new ImgMsg(msg);
    }else if (msg.elemType == MessageElemType.V2TIM_ELEM_TYPE_FILE.index) {
      return new FileTransferCard(fileId:msg.randID!, fileName: msg.fileElem!.filename, fileSize: msg.fileElem!.totalBytes, isSender: msg.senderId == Global.user.uuid,);
    }else if (msg.elemType == MessageElemType.V2TIM_ELEM_TYPE_P2P.index) {
      return new TextMsg(msg.textElem!.text!, widget.model);
    }else if (msg.elemType == MessageElemType.V2TIM_ELEM_TYPE_VOICE.index) {
      return new VoicePlayerWidget(filePath: msg.voiceElem!.filename!);
    } else {
      return new Text(Global.l10n.unknow_msg);
    }
    /*}else if ((msgType == "Text" || iosText) &&
        widget.model.msg.toString().contains("测试发送红包消息")) {
      return new RedPackage(widget.model);
    }  else if (msgType == 'Sound' || iosSound) {
      return new SoundMsg(widget.model);
//    } else if (msg.toString().contains('snapshotPath') &&
//        msg.toString().contains('videoPath')) {
//      return VideoMessage(msg, msgType, widget.data);
    } else if (msg['tipsType'] == 'Join') {
      return JoinMessage(msg);
    } else if (msg['tipsType'] == 'Quit') {
      return QuitMessage(msg);
    } else if (msg['groupInfoList'][0]['type'] == 'ModifyIntroduction') {
      return ModifyNotificationMessage(msg);
    } else if (msg['groupInfoList'][0]['type'] == 'ModifyName') {
      return ModifyGroupInfoMessage(msg);
    */

  }

  @override
  Widget build(BuildContext context) {

    return getWidgetWithTime(context, widget.model, widget.model_pre);
  }
}
