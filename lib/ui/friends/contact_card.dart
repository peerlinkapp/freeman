import 'package:freeman/common.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ContactCard extends StatelessWidget {
  final String img, title, nickName, id, area;
  final bool isBorder;
  final double lineWidth;
  final int sex;


  ContactCard({
    required this.img,
    required this.title,
    required this.id,
    required this.nickName,
    required this.area,
    this.isBorder = false,
    this.lineWidth = mainLineWidth,
    this.sex = 0
  });

  @override
  Widget build(BuildContext context) {

    String firstTitle = title.length == 0 ? nickName : title;
    String secondTitle = title.length == 0 ?  title: nickName;

    TextStyle labelStyle = TextStyle(fontSize: 14, color: mainTextColor);
    return Container(
      decoration: BoxDecoration(
        color: Global.settings.isDarkMode ? AppDarkColors.ChatBoxBg : AppColors.ChatBoxBg,
        border: isBorder
            ? Border(
                bottom: BorderSide(color: lineColor, width: lineWidth),
              )
            : null,
      ),
      width: winWidth(context),
      padding: EdgeInsets.only(right: 15.0, left: 15.0, bottom: 20.0, top:20.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          new GestureDetector(
            child: new ImageView(
                img: img, width: 55, height: 55, fit: BoxFit.cover),
            onTap: () {
              if (isNetWorkImg(img)) {
                routePush(
                  new PhotoView(
                    imageProvider: NetworkImage(img),
                    onTapUp: (c, f, s) => Navigator.of(context).pop(),
                    maxScale: 3.0,
                    minScale: 1.0,
                  ),
                );
              } else {
                showToast('无头像');
              }
            },
          ),
          new Space(width: mainSpace * 2),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text(
                    Utils.shortenString(firstTitle, 22, "...", Global.l10n.nick_name_null),
                    style: AppStyles.TitleStyle,
                  ),
                  new Space(width: mainSpace / 3),
                  new Image.asset(sex == 2? 'assets/images/contact/Contact_Female.webp':'assets/images/contact/Contact_Male.webp',
                      width: 20.0, fit: BoxFit.fill),
                ],
              ),
              new Padding(
                padding: EdgeInsets.only(top: 3.0),
                child: new Text((title.length == 0? Global.l10n.alias+":  " : Global.l10n.nick_name_txt+"  ") +  Utils.shortenString(secondTitle, 20, "---", "") , style: labelStyle),
              ),
              new Text(Global.l10n.app_id_name +" "+ Utils.shortenString(id, 26, "...", "") , style: labelStyle),
            ],
          )
        ],
      ),
    );
  }
}
