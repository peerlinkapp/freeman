import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:freeman/common.dart';

class SearchTileView extends StatelessWidget {
  final String text;
  final int type;
  final VoidCallback? onPressed;

  SearchTileView(this.text, {this.type = 0, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var bt = new TextButton(
      onPressed: onPressed ?? () {},
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: new Icon(
              Icons.map,
              color: Colors.green,
              size: 50.0,
            ),
          ),
          new Text(Global.l10n.tip_search),
          new Text(
            text,
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );

    var row = new Row(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: new Icon(Icons.map, color: Colors.green, size: 50.0),
        ),
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Text(Global.l10n.search),
                new Text(
                  text,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
            new Text(
              Global.l10n.search_others,
              style: TextStyle(color: mainTextColor),
            )
          ],
        )
      ],
    );

    if (type == 0) {
      return new Container(
        decoration: BoxDecoration(
            color: strNoEmpty(text) ?  Global.settings.isDarkMode ? AppDarkColors.ListItemBg :  AppColors.ListItemBg :  Global.settings.isDarkMode ? AppDarkColors.ListItemBg :  AppColors.ListItemBg,
            border: Border(
                top: BorderSide(
                    color: Colors.grey.withOpacity(0.2), width: 0.5))),
        width: Get.width,
        height: 65.0,
        child: strNoEmpty(text) ? bt : new Container(),
      );
    } else {
      return new Container(
        decoration: BoxDecoration(
          color:  Global.settings.isDarkMode ? AppDarkColors.ListItemBg :  AppColors.ListItemBg,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
          ),
        ),
        width: Get.width,
        height: 65.0,
        child: new TextButton(
          onPressed: () {},
          child: row,
        ),
      );
    }
  }
}
