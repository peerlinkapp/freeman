import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../global.dart';
import '../../model/v2_tim_message.dart';
import 'text_span_builder.dart';
import 'magic_pop.dart';
import 'package:freeman/common/win_media.dart';

class TextItemContainer extends StatefulWidget {
  final V2TimMessage msg;
  final String action;
  final bool? isMyself;


  TextItemContainer({required this.msg, required this.action, this.isMyself = true});

  @override
  _TextItemContainerState createState() => _TextItemContainerState();
}

class _TextItemContainerState extends State<TextItemContainer> {
  TextSpanBuilder _spanBuilder = TextSpanBuilder();
  String txtContent = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    txtContent = widget.msg.textElem!.text! ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return new MagicPop(
      onValueChanged: (int value) {
        switch (value) {
          case 0:
            Clipboard.setData(new ClipboardData(text: txtContent ));
            break;
          case 1:
            Global.dhtClient.delMsg(widget.msg.id ?? 0);
            break;
        }
      },
      pressType: PressType.longPress,
      actions: [Global.l10n.chat_pop_copy, Global.l10n.chat_pop_del],
      child: new Container(
        width: txtContent.length > 24 ? (winWidth(context) - 66) - 100 : null,
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: (widget.isMyself?? false)
              ? Global.settings.isDarkMode ? AppDarkColors.MsgMeBgColor : AppColors.MsgMeBgColor
              : Global.settings.isDarkMode ? AppDarkColors.MsgOthersBgColor : AppColors.MsgOthersBgColor,  //
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        margin: EdgeInsets.only(right: 7.0),
        child: ExtendedText(
          txtContent ?? '文字为空',
          maxLines: 99,
          overflow: TextOverflow.ellipsis,
          specialTextSpanBuilder: _spanBuilder,
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
