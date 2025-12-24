
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freeman/common.dart';
import 'package:freeman/ui/chatdetail/msg_avatar.dart';

import '../../model/v2_tim_message.dart';

/**
 * 文本型消息，每条，UI
 *
 */

class TextMsg extends StatelessWidget {
  final String text;
  final V2TimMessage model;

  TextMsg(this.text, this.model);

  @override
  Widget build(BuildContext context) {
    final bool self = model.senderId == Global.user.uuid;
    var body = [
      new MsgAvatar(model: model),
      new TextItemContainer(
        msg: model,
        action: '',
        isMyself: self
      ),
      new Spacer(),
    ];

    //使空格靠左，文字靠右
    if (self) {
      body = body.reversed.toList();
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(children: body),
    );
  }
}
