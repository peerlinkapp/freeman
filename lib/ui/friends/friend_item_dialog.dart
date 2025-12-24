import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:freeman/ui/friends/friend_handle.dart';
import 'package:freeman/common.dart';

import 'set_remark_page.dart';

friendItemDialog(BuildContext context,
    {required String userId, required OnSuCc suCc}) {
      action(v) {
        Navigator.of(context).pop();
        if (v == Global.l10n.del) {
          confirmAlert(
            context,
                (bool) {
              if (bool) {
                delFriend(userId, context, suCc: (v) => suCc(v));
              }
            },
            tips: Global.l10n.del_sure,
            okBtn: Global.l10n.del,
            warmStr: Global.l10n.del_contact,
            isWarm: true,
            style: TextStyle(fontWeight: FontWeight.w500),
          );
        }else if(v == Global.l10n.contact_remark)
        {
          //Get.to<void>(SetRemarkPage());
        } else{
          showToast(Global.l10n.n_a);
        }
      }

      Widget item(String item) {
        return new Container(
          width: Get.width,
          decoration: BoxDecoration(
            border: item != '删除'
                ? Border(
                    bottom: BorderSide(color: lineColor, width: 0.2),
                  )
                : null,
          ),
          child: new TextButton(
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15.0)),
              backgroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () => action(item),
            child: new Text(item),
          ),
        );
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          List<String> data = [
            '设置朋友圈权限',
            '加入黑名单',
            '删除',
          ];

          return new Center(
            child: new Material(
              type: MaterialType.transparency,
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    child: new InkWell(
                      child: new Container(color: Colors.transparent),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  new ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    child: new Container(
                      color: Colors.white,
                      child: new Column(
                        children: <Widget>[
                          new Column(children: data.map(item).toList()),
                          new HorizontalLine(color: appBarColor, height: 10.0),
                          new TextButton(
                            style: ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 15.0)),
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.white)),
                            onPressed: () => Navigator.of(context).pop(),
                            child: new Container(
                              width: Get.width,
                              alignment: Alignment.center,
                              child: new Text('取消'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
}
