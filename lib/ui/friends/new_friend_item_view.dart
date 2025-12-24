import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'package:get/get.dart';
import '../../model/v2_tim_message.dart';
import '../content_msg.dart';

class NewFriendItemView extends StatefulWidget {
  final String? imageUrl;
  final String? title;
  final String content;
  final String hashid;
  final Widget? time;
  final bool isBorder;
  final VoidCallback? onPressed;

  const NewFriendItemView({
    Key? key,
    this.imageUrl,
    this.title,
    required this.content,
    required this.hashid,
    this.time,
    this.isBorder = true,
    this.onPressed,
  }) : super(key: key);

  @override
  _NewFriendItemViewState createState() => _NewFriendItemViewState();
}

class _NewFriendItemViewState extends State<NewFriendItemView> {
  @override
  Widget build(BuildContext context) {

    String desc =  widget.content.substring(0, 10)+"..."+widget.content.substring(30);

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
              Text(desc, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
        SizedBox(width: mainSpace),
        Column(
          children: [
            widget.time ?? SizedBox.shrink(),
            Icon(Icons.flag, color: Colors.transparent),
          ],
        ),
        SizedBox(width: mainSpace),
        Container(
          width: 7.0,
          child: Image.asset(
            'assets/images/ic_right_arrow_grey.webp',
            color: mainTextColor.withOpacity(0.5),
            fit: BoxFit.cover,
          ),
        ),
      ],
    );


    return Container(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Global.settings.isDarkMode ? AppDarkColors.BackgroundColor : AppColors.BackgroundColor,
          padding: EdgeInsets.all(10),
        ),
        onPressed: widget.onPressed ?? () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImageView(
                img: widget.imageUrl ?? "",
                height: 50.0,
                width: 50.0,
                fit: BoxFit.cover),
            Container(
              padding: EdgeInsets.only(right: 18.0, top: 12.0, bottom: 12.0),
              width: Get.width - 72,
              
              child: row,
            ),
          ],
        ),
      ),
    );
  }
}
