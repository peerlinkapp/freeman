import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../model/v2_tim_message.dart';
import '../content_msg.dart';

class MyConversationView extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String? title;
  final V2TimMessage? content;
  final Widget? time;
  final bool isBorder;
  final int unreadCount;

  const MyConversationView({
    Key? key,
    this.imageUrl,
    this.title,
    this.content,
    this.time,
    this.isBorder = true,
    this.unreadCount = 0
  }) : super(key: key);

  @override
  _MyConversationViewState createState() => _MyConversationViewState();
}

class _MyConversationViewState extends ConsumerState<MyConversationView> {
  @override
  Widget build(BuildContext context) {
    //print("image:${widget.imageUrl}");

    var row = Row(
      children: <Widget>[
        SizedBox(width: mainSpace),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.title ?? '',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 2.0),
              ContentMsg(widget.content),
            ],
          ),
        ),
        SizedBox(width: mainSpace),
        Column(
          children: [
            widget.time ?? SizedBox.shrink(),
            Icon(Icons.flag, color: Colors.transparent),
          ],
        )
      ],
    );

    final settings = ref.read(mySettingsProvider);
    return Container(
      padding: EdgeInsets.only(left: 18.0),
      color: settings.isDarkMode ? AppDarkColors.ListItemBg :  AppColors.ListItemBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImageView(
              img: widget.imageUrl ?? "",
              height: 50.0,
              width: 50.0,
              fit: BoxFit.cover,
              unreadCount: widget.unreadCount,
          ),
          Container(
            padding: EdgeInsets.only(right: 18.0, top: 12.0, bottom: 12.0),
            width: Get.width - 68,
            decoration: BoxDecoration(
              border: widget.isBorder
                  ? Border(
                      top: BorderSide(color: lineColor, width: 0.2),
                    )
                  : null,
            ),
            child: row,
          )
        ],
      ),
    );
  }
}
