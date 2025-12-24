import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeman/common.dart';

typedef OnSuCc = void Function(bool v);



Future<dynamic> delFriend(String userHashId, BuildContext context, {OnSuCc? suCc}) async
{
  try {
    print("delFriend: "+userHashId);
    Global.dhtClient.delContact(userHashId);

    if (suCc == null) {
      popToHomePage(context);
    } else {
      suCc(true);
    }

    return 0;
  } on PlatformException {
    debugPrint('删除好友  失败');
  }
}