
import 'package:flutter/material.dart';
import 'package:freeman/constants.dart';
import '../../common/check.dart';
import '../../global.dart';
import 'message_handler.dart';
import '../../model/data.dart';
import '../../model/notice.dart';

class ChatDetailsRow extends StatefulWidget {
  final GestureTapCallback voiceOnTap;
  final bool? isVoice;
  final LayoutWidgetBuilder? edit;
  final VoidCallback? onEmojio;
  final Widget? more;
  final String? id;
  final int? type;

  ChatDetailsRow({
    required this.voiceOnTap,
    this.isVoice,
    this.edit,
    this.more,
    this.id,
    this.type,
    this.onEmojio,
  });

  ChatDetailsRowState createState() => ChatDetailsRowState();
}

class ChatDetailsRowState extends State<ChatDetailsRow> {
  String? path;

  @override
  void initState() {
    super.initState();

    Notice.addListener(WeChatActions.voiceImg(), (v) {
      if (!v) return;
      if (!strNoEmpty(path)) return;
      sendSoundMessages(
        widget.id ?? "",
        path ?? "",
        2,
        widget.type ?? 0,
        (value) => Notice.send(WeChatActions.msg(), v ?? ''),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child:           new Container(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color:  Global.settings.isDarkMode ? AppDarkColors.ChatBoxBg : AppColors.ChatBoxBg,
          border: Border(
            top: BorderSide(color: lineColor, width: Constants.DividerWidth),
            bottom: BorderSide(color: lineColor, width: Constants.DividerWidth),
          ),
        ),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new InkWell(
              child: new Image.asset('assets/images/chat/ic_voice.webp',
                  width: 25, color: mainTextColor),
              onTap: () {
                if (widget.voiceOnTap != null) {
                  widget.voiceOnTap();
                }
              },
            ),
            new Expanded(
              child: new Container(
                margin: const EdgeInsets.only(
                    top: 7.0, bottom: 7.0, left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0)),
                child: widget.isVoice ?? false
                    ?
                new LayoutBuilder(builder: widget.edit ?? (context, constraints) => Container())
                /*new ChatVoice(
                  voiceFile: (path) {
                    setState(() => this.path = path);
                  },
                )*/
                    : new LayoutBuilder(builder: widget.edit ?? (context, constraints) => Container()),
              ),
            ),
            new InkWell(
              child: new Image.asset('assets/images/chat/ic_Emotion.webp',
                  width: 30, fit: BoxFit.cover),
              onTap: () {
                (widget.onEmojio ?? () {}).call();
              },
            ),
            widget.more ?? Container(),
          ],
        ),
      ),
      onTap: () {},
    );
  }

}
