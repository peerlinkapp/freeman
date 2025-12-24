
import 'package:freeman/model/v2_tim_conversation.dart';
import 'package:freeman/model/v2_tim_message.dart';
import 'package:freeman/model/message_elem_type.dart';
import 'package:freeman/common.dart';
import '../common/check.dart';

//会话列表页数据

class ChatListData {
  Future<bool> isNull() async {
    return false;
  }

  Future<List<V2TimConversation?>> chatListData() async {

    List<V2TimConversation> result = [];

    List<Conversation> conversations = await  Global.getConversations();

    conversations.forEach((c){
      var m = V2TimMessage(elemType: MessageElemType.V2TIM_ELEM_TYPE_TEXT.index);
      if(c.lastMsg != null) {
        m.timestamp = c.lastMsg!.updateTime;
        if (c.lastMsg!.msgType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
          m.textElem = V2TimTextElem(text: c.lastMsg!.content);
        }else if(c.lastMsg!.msgType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE){
          m.textElem = V2TimTextElem(text: "["+Global.l10n.msg_type_img+"]");
        }else if(c.lastMsg!.msgType == MessageElemType.V2TIM_ELEM_TYPE_FILE){
          m.textElem = V2TimTextElem(text: "["+Global.l10n.chat_file+"]");
        }else if(c.lastMsg!.msgType == MessageElemType.V2TIM_ELEM_TYPE_VOICE){
          m.textElem = V2TimTextElem(text: "["+Global.l10n.chat_voice+"]");
        }
        //print("[chat_list_data] c.showName:[${c.showName}] faceurl: ${c.faceUrl}, time:${ m.timestamp}");
        var v = V2TimConversation(
            conversationID:c.id,
            showName: c.showName,
            faceUrl:  c.faceUrl  ,
            lastMessage:m,
            type: 0,
            isPinned: c.istop > 0,
            unreadCount: c.unreadCount
        );
        //print("[chat_list_data] vvv  ${v.showName} isPinned: ${v.isPinned}");


        result.add(v);
      }else{
        m.timestamp = c.createTime;
      }


    });


    result.sort((a, b) {
      int timestampA = a.lastMessage?.timestamp ?? double.infinity.toInt();
      int timestampB = b.lastMessage?.timestamp ?? double.infinity.toInt();


      int topA =  0;
      int topB =  0;
      if(a.isPinned != null)
      {
        topA = a.isPinned! ? 1 : 0;
      }
      if(b.isPinned != null)
      {
        topB = b.isPinned! ? 1 : 0;
      }

      if(topA.compareTo(topB) > 0)
      {
        return 0;
      }else{
        return  timestampB.compareTo(timestampA);
      }


    });

    return result;
  }
}
