export 'dart:io';
export 'package:get/get.dart';
export 'package:freeman/constants.dart';
export 'package:freeman/my_app_settings.dart';
export 'package:freeman/global.dart';
export 'package:freeman/common/ui.dart';
export 'package:freeman/common/utils.dart';
export 'package:freeman/common/route.dart';
export 'package:freeman/common/check.dart';
export 'package:freeman/common/ui/indicator_page_view.dart';
export 'package:freeman/common/ui/commom_bar.dart';
export 'package:freeman/common/ui/w_popup_menu.dart';
export 'package:freeman/common/ui/menu_popup_widget.dart';
export 'package:freeman/common/ui/list_tile_view.dart';
export 'package:freeman/common/utils/datetime.dart';
export 'package:freeman/model/user.dart';
export 'package:freeman/model/data.dart';
export 'package:freeman/model/notice.dart';
export 'package:freeman/model/chat_data.dart';
export 'package:freeman/model/contacts.dart';
export 'package:freeman/model/conversations.dart';
export 'package:freeman/model/conversation_type.dart';
export 'package:freeman/model/messages.dart';
export 'package:freeman/model/message_elem_type.dart';
export 'package:freeman/model/v2_tim_text_elem.dart';
export 'package:freeman/model/posts.dart';
export 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
/*
* 屏幕适配
* SizeConfig().init(context); 初始化
* height: SizeConfig.blockSizeVertical * 20,
* width: SizeConfig.blockSizeHorizontal * 50,
*
* screen
* width: SizeConfig.screenWidth,
* height: SizeConfig.screenHeight,
*
* 字体 （均可）
* SizeConfig.safeBlockHorizontal
* SizeConfig.blockSizeVertical
*
***/

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical!) / 100;
  }
}