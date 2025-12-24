import 'package:flutter/material.dart';
import 'package:freeman/common.dart';

class ChatMoreIcon extends StatelessWidget {
  final bool? isMore;
  final String value;
  final VoidCallback onTap;
  final GestureTapCallback moreTap;

  ChatMoreIcon({
    this.isMore = false,
    required this.value,
    required this.onTap,
    required this.moreTap,
  });

  @override
  Widget build(BuildContext context) {
    return strNoEmpty(value)
        ? new ComMomButton(
            text: Global.l10n.btn_send,
            style: TextStyle(color: Colors.white),
            width: 55.0,
            margin: EdgeInsets.all(10.0),
            radius: 4.0,
            onTap: onTap ?? () {},
          )
        : new InkWell(
            child: new Container(
              width: 23,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: new Image.asset(
                'assets/images/chat/ic_chat_more.webp',
                color: mainTextColor,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              if (moreTap != null) {
                moreTap();
              }
            },
          );
  }
}
