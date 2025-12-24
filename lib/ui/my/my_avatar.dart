
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:freeman/common.dart';

class MyLogo  {

  static Widget getCircleAvatar()
  {
    return ClipOval(
      child: Utils.isEmptyStr(Global.user.avatar)
          ? new Image.asset(defIcon, fit: BoxFit.cover)
          : Image.file(File(Global.user.avatar), width: 200,
          height: 200,
          fit: BoxFit.cover),
    );
  }

  static Widget getRectAvatar()
  {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Utils.isEmptyStr(Global.user.avatar)
            ? new Image.asset(defIcon, fit: BoxFit.cover)
            : Image.file(File(Global.user.avatar), width: 200,
            height: 200,
            fit: BoxFit.cover)
    );
  }
}